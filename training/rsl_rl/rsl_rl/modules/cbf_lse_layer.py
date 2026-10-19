import torch
import torch.nn as nn
import torch.nn.functional as F
import numpy as np

class ExactLSECBFLayer(nn.Module):
    def __init__(self,
                 num_rays=41,
                 fov_deg=180.0,
                 safe_radius=0.15,
                 safety_margin=0.05,
                 kappa=10.0,
                 damping_factor=1.0):
        super().__init__()
        
        self.d_safe = safe_radius + safety_margin
        self.kappa = kappa
        self.damping_factor = damping_factor
        
        # Pre-calculate unit direction vectors n_i
        start_angle = -np.deg2rad(fov_deg) / 2
        end_angle = np.deg2rad(fov_deg) / 2
        angles = torch.linspace(start_angle, end_angle, num_rays)
        self.register_buffer('ray_unit_vectors',
            torch.stack([torch.cos(angles), torch.sin(angles)], dim=1))

    def forward(self, u_bar, lidar_dists, alpha):
        """
        u_bar: [B, 2] Nominal policy (vx, yaw_rate)
        lidar_dists: [B, num_rays] Lidar distances (processed externally to 0.1~5.0)
        alpha: [B, 1] Class-K function parameter (adaptively learned)
        """
        forward_speed = u_bar[:, :1]
        yaw_rate = u_bar[:, 1:]

        # 1. Calculate independent h_i(x)
        h_i = lidar_dists - self.d_safe  # [B, num_rays]

        # 2. Calculate composite CBF: h(x) (Corresponding to Eq. 14 in the paper)
        min_h, _ = torch.min(h_i, dim=1, keepdim=True) 
        h_comp = min_h - (1.0 / self.kappa) * torch.log(
            torch.sum(torch.exp(-self.kappa * (h_i - min_h)), dim=1, keepdim=True)
        ) # [B, 1]

        # 3. Calculate \lambda_i(x)
        lambda_i = torch.exp(-self.kappa * (h_i - h_comp)).unsqueeze(-1) # [B, num_rays, 1]

        # 4. Calculate L_g h(x) for forward-only translation.
        # d_dot_i = -cos(theta_i) * vx; yaw does not change range to a fixed obstacle.
        ray_forward = self.ray_unit_vectors[:, 0].view(1, -1, 1)
        Lg_h = -torch.sum(lambda_i * ray_forward, dim=1) # [B, 1]

        # 5. Calculate \eta(x)
        # \eta = - (L_f h + L_g h * u_bar + \alpha * h) / ||L_g h||^2 # Note: L_f h = 0
        Lgh_u = Lg_h * forward_speed # [B, 1]
        Lgh_norm_sq = torch.sum(Lg_h**2, dim=1, keepdim=True) # [B, 1]
        
        damping_factor = self.damping_factor  # Larger means smoother, but slightly sacrifices safety
        eta = - (Lgh_u + alpha * h_comp) / (Lgh_norm_sq + damping_factor)

        # 6. Calculate safe action u_s(x)
        u_s_forward = forward_speed + F.relu(eta) * Lg_h # [B, 1]

        u_s = torch.cat((u_s_forward, yaw_rate), dim=-1) # [B, 2]

        return u_s
