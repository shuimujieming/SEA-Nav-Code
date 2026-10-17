;; Auto-generated. Do not edit!


(when (boundp 'seanav_deploy_ros1::SeaNavObservation)
  (if (not (find-package "SEANAV_DEPLOY_ROS1"))
    (make-package "SEANAV_DEPLOY_ROS1"))
  (shadow 'SeaNavObservation (find-package "SEANAV_DEPLOY_ROS1")))
(unless (find-package "SEANAV_DEPLOY_ROS1::SEANAVOBSERVATION")
  (make-package "SEANAV_DEPLOY_ROS1::SEANAVOBSERVATION"))

(in-package "ROS")
;;//! \htmlinclude SeaNavObservation.msg.html
(if (not (find-package "STD_MSGS"))
  (ros::roseus-add-msgs "std_msgs"))


(defclass seanav_deploy_ros1::SeaNavObservation
  :super ros::object
  :slots (_header _history_length _step_size _observation _proprioception _rays_m _rays_log2 _goal_local _previous_nav_command _valid ))

(defmethod seanav_deploy_ros1::SeaNavObservation
  (:init
   (&key
    ((:header __header) (instance std_msgs::Header :init))
    ((:history_length __history_length) 0)
    ((:step_size __step_size) 0)
    ((:observation __observation) (make-array 0 :initial-element 0.0 :element-type :float))
    ((:proprioception __proprioception) (make-array 0 :initial-element 0.0 :element-type :float))
    ((:rays_m __rays_m) (make-array 0 :initial-element 0.0 :element-type :float))
    ((:rays_log2 __rays_log2) (make-array 0 :initial-element 0.0 :element-type :float))
    ((:goal_local __goal_local) (make-array 0 :initial-element 0.0 :element-type :float))
    ((:previous_nav_command __previous_nav_command) (make-array 0 :initial-element 0.0 :element-type :float))
    ((:valid __valid) nil)
    )
   (send-super :init)
   (setq _header __header)
   (setq _history_length (round __history_length))
   (setq _step_size (round __step_size))
   (setq _observation __observation)
   (setq _proprioception __proprioception)
   (setq _rays_m __rays_m)
   (setq _rays_log2 __rays_log2)
   (setq _goal_local __goal_local)
   (setq _previous_nav_command __previous_nav_command)
   (setq _valid __valid)
   self)
  (:header
   (&rest __header)
   (if (keywordp (car __header))
       (send* _header __header)
     (progn
       (if __header (setq _header (car __header)))
       _header)))
  (:history_length
   (&optional __history_length)
   (if __history_length (setq _history_length __history_length)) _history_length)
  (:step_size
   (&optional __step_size)
   (if __step_size (setq _step_size __step_size)) _step_size)
  (:observation
   (&optional __observation)
   (if __observation (setq _observation __observation)) _observation)
  (:proprioception
   (&optional __proprioception)
   (if __proprioception (setq _proprioception __proprioception)) _proprioception)
  (:rays_m
   (&optional __rays_m)
   (if __rays_m (setq _rays_m __rays_m)) _rays_m)
  (:rays_log2
   (&optional __rays_log2)
   (if __rays_log2 (setq _rays_log2 __rays_log2)) _rays_log2)
  (:goal_local
   (&optional __goal_local)
   (if __goal_local (setq _goal_local __goal_local)) _goal_local)
  (:previous_nav_command
   (&optional __previous_nav_command)
   (if __previous_nav_command (setq _previous_nav_command __previous_nav_command)) _previous_nav_command)
  (:valid
   (&optional (__valid :null))
   (if (not (eq __valid :null)) (setq _valid __valid)) _valid)
  (:serialization-length
   ()
   (+
    ;; std_msgs/Header _header
    (send _header :serialization-length)
    ;; uint32 _history_length
    4
    ;; uint32 _step_size
    4
    ;; float32[] _observation
    (* 4    (length _observation)) 4
    ;; float32[] _proprioception
    (* 4    (length _proprioception)) 4
    ;; float32[] _rays_m
    (* 4    (length _rays_m)) 4
    ;; float32[] _rays_log2
    (* 4    (length _rays_log2)) 4
    ;; float32[] _goal_local
    (* 4    (length _goal_local)) 4
    ;; float32[] _previous_nav_command
    (* 4    (length _previous_nav_command)) 4
    ;; bool _valid
    1
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; std_msgs/Header _header
       (send _header :serialize s)
     ;; uint32 _history_length
       (write-long _history_length s)
     ;; uint32 _step_size
       (write-long _step_size s)
     ;; float32[] _observation
     (write-long (length _observation) s)
     (dotimes (i (length _observation))
       (sys::poke (elt _observation i) (send s :buffer) (send s :count) :float) (incf (stream-count s) 4)
       )
     ;; float32[] _proprioception
     (write-long (length _proprioception) s)
     (dotimes (i (length _proprioception))
       (sys::poke (elt _proprioception i) (send s :buffer) (send s :count) :float) (incf (stream-count s) 4)
       )
     ;; float32[] _rays_m
     (write-long (length _rays_m) s)
     (dotimes (i (length _rays_m))
       (sys::poke (elt _rays_m i) (send s :buffer) (send s :count) :float) (incf (stream-count s) 4)
       )
     ;; float32[] _rays_log2
     (write-long (length _rays_log2) s)
     (dotimes (i (length _rays_log2))
       (sys::poke (elt _rays_log2 i) (send s :buffer) (send s :count) :float) (incf (stream-count s) 4)
       )
     ;; float32[] _goal_local
     (write-long (length _goal_local) s)
     (dotimes (i (length _goal_local))
       (sys::poke (elt _goal_local i) (send s :buffer) (send s :count) :float) (incf (stream-count s) 4)
       )
     ;; float32[] _previous_nav_command
     (write-long (length _previous_nav_command) s)
     (dotimes (i (length _previous_nav_command))
       (sys::poke (elt _previous_nav_command i) (send s :buffer) (send s :count) :float) (incf (stream-count s) 4)
       )
     ;; bool _valid
       (if _valid (write-byte -1 s) (write-byte 0 s))
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; std_msgs/Header _header
     (send _header :deserialize buf ptr-) (incf ptr- (send _header :serialization-length))
   ;; uint32 _history_length
     (setq _history_length (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;; uint32 _step_size
     (setq _step_size (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;; float32[] _observation
   (let (n)
     (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4)
     (setq _observation (instantiate float-vector n))
     (dotimes (i n)
     (setf (elt _observation i) (sys::peek buf ptr- :float)) (incf ptr- 4)
     ))
   ;; float32[] _proprioception
   (let (n)
     (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4)
     (setq _proprioception (instantiate float-vector n))
     (dotimes (i n)
     (setf (elt _proprioception i) (sys::peek buf ptr- :float)) (incf ptr- 4)
     ))
   ;; float32[] _rays_m
   (let (n)
     (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4)
     (setq _rays_m (instantiate float-vector n))
     (dotimes (i n)
     (setf (elt _rays_m i) (sys::peek buf ptr- :float)) (incf ptr- 4)
     ))
   ;; float32[] _rays_log2
   (let (n)
     (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4)
     (setq _rays_log2 (instantiate float-vector n))
     (dotimes (i n)
     (setf (elt _rays_log2 i) (sys::peek buf ptr- :float)) (incf ptr- 4)
     ))
   ;; float32[] _goal_local
   (let (n)
     (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4)
     (setq _goal_local (instantiate float-vector n))
     (dotimes (i n)
     (setf (elt _goal_local i) (sys::peek buf ptr- :float)) (incf ptr- 4)
     ))
   ;; float32[] _previous_nav_command
   (let (n)
     (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4)
     (setq _previous_nav_command (instantiate float-vector n))
     (dotimes (i n)
     (setf (elt _previous_nav_command i) (sys::peek buf ptr- :float)) (incf ptr- 4)
     ))
   ;; bool _valid
     (setq _valid (not (= 0 (sys::peek buf ptr- :char)))) (incf ptr- 1)
   ;;
   self)
  )

(setf (get seanav_deploy_ros1::SeaNavObservation :md5sum-) "49556c39313f8db6d5691b565aef1b41")
(setf (get seanav_deploy_ros1::SeaNavObservation :datatype-) "seanav_deploy_ros1/SeaNavObservation")
(setf (get seanav_deploy_ros1::SeaNavObservation :definition-)
      "std_msgs/Header header

# One step is 55 values; history is oldest-to-newest and flattened.
# [gravity(3), previous_nav_command(3), body_lin_vel(3), body_ang_vel(3),
#  log2(rays_m)(41), goal_local_xy(2)] repeated history_length times.
uint32 history_length
uint32 step_size
float32[] observation

# Current unflattened values are included for inspection and debugging.
float32[] proprioception
float32[] rays_m
float32[] rays_log2
# Last accepted target in body XY, available with a fresh pose even if valid=false.
# Empty until a target is set, or when pose is missing/stale.
float32[] goal_local
float32[] previous_nav_command

bool valid

================================================================================
MSG: std_msgs/Header
# Standard metadata for higher-level stamped data types.
# This is generally used to communicate timestamped data 
# in a particular coordinate frame.
# 
# sequence ID: consecutively increasing ID 
uint32 seq
#Two-integer timestamp that is expressed as:
# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')
# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')
# time-handling sugar is provided by the client library
time stamp
#Frame this data is associated with
string frame_id

")



(provide :seanav_deploy_ros1/SeaNavObservation "49556c39313f8db6d5691b565aef1b41")


