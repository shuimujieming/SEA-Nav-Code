;; Auto-generated. Do not edit!


(when (boundp 'seanav_deploy_ros1::Lite3State)
  (if (not (find-package "SEANAV_DEPLOY_ROS1"))
    (make-package "SEANAV_DEPLOY_ROS1"))
  (shadow 'Lite3State (find-package "SEANAV_DEPLOY_ROS1")))
(unless (find-package "SEANAV_DEPLOY_ROS1::LITE3STATE")
  (make-package "SEANAV_DEPLOY_ROS1::LITE3STATE"))

(in-package "ROS")
;;//! \htmlinclude Lite3State.msg.html
(if (not (find-package "STD_MSGS"))
  (ros::roseus-add-msgs "std_msgs"))


(defclass seanav_deploy_ros1::Lite3State
  :super ros::object
  :slots (_header _joint_names _joint_position _joint_velocity _joint_torque _projected_gravity _base_linear_velocity _base_angular_velocity _last_loco_action _last_nav_command _standing _enabled ))

(defmethod seanav_deploy_ros1::Lite3State
  (:init
   (&key
    ((:header __header) (instance std_msgs::Header :init))
    ((:joint_names __joint_names) (let (r) (dotimes (i 0) (push "" r)) r))
    ((:joint_position __joint_position) (make-array 0 :initial-element 0.0 :element-type :float))
    ((:joint_velocity __joint_velocity) (make-array 0 :initial-element 0.0 :element-type :float))
    ((:joint_torque __joint_torque) (make-array 0 :initial-element 0.0 :element-type :float))
    ((:projected_gravity __projected_gravity) (make-array 0 :initial-element 0.0 :element-type :float))
    ((:base_linear_velocity __base_linear_velocity) (make-array 0 :initial-element 0.0 :element-type :float))
    ((:base_angular_velocity __base_angular_velocity) (make-array 0 :initial-element 0.0 :element-type :float))
    ((:last_loco_action __last_loco_action) (make-array 0 :initial-element 0.0 :element-type :float))
    ((:last_nav_command __last_nav_command) (make-array 0 :initial-element 0.0 :element-type :float))
    ((:standing __standing) nil)
    ((:enabled __enabled) nil)
    )
   (send-super :init)
   (setq _header __header)
   (setq _joint_names __joint_names)
   (setq _joint_position __joint_position)
   (setq _joint_velocity __joint_velocity)
   (setq _joint_torque __joint_torque)
   (setq _projected_gravity __projected_gravity)
   (setq _base_linear_velocity __base_linear_velocity)
   (setq _base_angular_velocity __base_angular_velocity)
   (setq _last_loco_action __last_loco_action)
   (setq _last_nav_command __last_nav_command)
   (setq _standing __standing)
   (setq _enabled __enabled)
   self)
  (:header
   (&rest __header)
   (if (keywordp (car __header))
       (send* _header __header)
     (progn
       (if __header (setq _header (car __header)))
       _header)))
  (:joint_names
   (&optional __joint_names)
   (if __joint_names (setq _joint_names __joint_names)) _joint_names)
  (:joint_position
   (&optional __joint_position)
   (if __joint_position (setq _joint_position __joint_position)) _joint_position)
  (:joint_velocity
   (&optional __joint_velocity)
   (if __joint_velocity (setq _joint_velocity __joint_velocity)) _joint_velocity)
  (:joint_torque
   (&optional __joint_torque)
   (if __joint_torque (setq _joint_torque __joint_torque)) _joint_torque)
  (:projected_gravity
   (&optional __projected_gravity)
   (if __projected_gravity (setq _projected_gravity __projected_gravity)) _projected_gravity)
  (:base_linear_velocity
   (&optional __base_linear_velocity)
   (if __base_linear_velocity (setq _base_linear_velocity __base_linear_velocity)) _base_linear_velocity)
  (:base_angular_velocity
   (&optional __base_angular_velocity)
   (if __base_angular_velocity (setq _base_angular_velocity __base_angular_velocity)) _base_angular_velocity)
  (:last_loco_action
   (&optional __last_loco_action)
   (if __last_loco_action (setq _last_loco_action __last_loco_action)) _last_loco_action)
  (:last_nav_command
   (&optional __last_nav_command)
   (if __last_nav_command (setq _last_nav_command __last_nav_command)) _last_nav_command)
  (:standing
   (&optional (__standing :null))
   (if (not (eq __standing :null)) (setq _standing __standing)) _standing)
  (:enabled
   (&optional (__enabled :null))
   (if (not (eq __enabled :null)) (setq _enabled __enabled)) _enabled)
  (:serialization-length
   ()
   (+
    ;; std_msgs/Header _header
    (send _header :serialization-length)
    ;; string[] _joint_names
    (apply #'+ (mapcar #'(lambda (x) (+ 4 (length x))) _joint_names)) 4
    ;; float32[] _joint_position
    (* 4    (length _joint_position)) 4
    ;; float32[] _joint_velocity
    (* 4    (length _joint_velocity)) 4
    ;; float32[] _joint_torque
    (* 4    (length _joint_torque)) 4
    ;; float32[] _projected_gravity
    (* 4    (length _projected_gravity)) 4
    ;; float32[] _base_linear_velocity
    (* 4    (length _base_linear_velocity)) 4
    ;; float32[] _base_angular_velocity
    (* 4    (length _base_angular_velocity)) 4
    ;; float32[] _last_loco_action
    (* 4    (length _last_loco_action)) 4
    ;; float32[] _last_nav_command
    (* 4    (length _last_nav_command)) 4
    ;; bool _standing
    1
    ;; bool _enabled
    1
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; std_msgs/Header _header
       (send _header :serialize s)
     ;; string[] _joint_names
     (write-long (length _joint_names) s)
     (dolist (elem _joint_names)
       (write-long (length elem) s) (princ elem s)
       )
     ;; float32[] _joint_position
     (write-long (length _joint_position) s)
     (dotimes (i (length _joint_position))
       (sys::poke (elt _joint_position i) (send s :buffer) (send s :count) :float) (incf (stream-count s) 4)
       )
     ;; float32[] _joint_velocity
     (write-long (length _joint_velocity) s)
     (dotimes (i (length _joint_velocity))
       (sys::poke (elt _joint_velocity i) (send s :buffer) (send s :count) :float) (incf (stream-count s) 4)
       )
     ;; float32[] _joint_torque
     (write-long (length _joint_torque) s)
     (dotimes (i (length _joint_torque))
       (sys::poke (elt _joint_torque i) (send s :buffer) (send s :count) :float) (incf (stream-count s) 4)
       )
     ;; float32[] _projected_gravity
     (write-long (length _projected_gravity) s)
     (dotimes (i (length _projected_gravity))
       (sys::poke (elt _projected_gravity i) (send s :buffer) (send s :count) :float) (incf (stream-count s) 4)
       )
     ;; float32[] _base_linear_velocity
     (write-long (length _base_linear_velocity) s)
     (dotimes (i (length _base_linear_velocity))
       (sys::poke (elt _base_linear_velocity i) (send s :buffer) (send s :count) :float) (incf (stream-count s) 4)
       )
     ;; float32[] _base_angular_velocity
     (write-long (length _base_angular_velocity) s)
     (dotimes (i (length _base_angular_velocity))
       (sys::poke (elt _base_angular_velocity i) (send s :buffer) (send s :count) :float) (incf (stream-count s) 4)
       )
     ;; float32[] _last_loco_action
     (write-long (length _last_loco_action) s)
     (dotimes (i (length _last_loco_action))
       (sys::poke (elt _last_loco_action i) (send s :buffer) (send s :count) :float) (incf (stream-count s) 4)
       )
     ;; float32[] _last_nav_command
     (write-long (length _last_nav_command) s)
     (dotimes (i (length _last_nav_command))
       (sys::poke (elt _last_nav_command i) (send s :buffer) (send s :count) :float) (incf (stream-count s) 4)
       )
     ;; bool _standing
       (if _standing (write-byte -1 s) (write-byte 0 s))
     ;; bool _enabled
       (if _enabled (write-byte -1 s) (write-byte 0 s))
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; std_msgs/Header _header
     (send _header :deserialize buf ptr-) (incf ptr- (send _header :serialization-length))
   ;; string[] _joint_names
   (let (n)
     (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4)
     (setq _joint_names (make-list n))
     (dotimes (i n)
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setf (elt _joint_names i) (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
     ))
   ;; float32[] _joint_position
   (let (n)
     (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4)
     (setq _joint_position (instantiate float-vector n))
     (dotimes (i n)
     (setf (elt _joint_position i) (sys::peek buf ptr- :float)) (incf ptr- 4)
     ))
   ;; float32[] _joint_velocity
   (let (n)
     (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4)
     (setq _joint_velocity (instantiate float-vector n))
     (dotimes (i n)
     (setf (elt _joint_velocity i) (sys::peek buf ptr- :float)) (incf ptr- 4)
     ))
   ;; float32[] _joint_torque
   (let (n)
     (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4)
     (setq _joint_torque (instantiate float-vector n))
     (dotimes (i n)
     (setf (elt _joint_torque i) (sys::peek buf ptr- :float)) (incf ptr- 4)
     ))
   ;; float32[] _projected_gravity
   (let (n)
     (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4)
     (setq _projected_gravity (instantiate float-vector n))
     (dotimes (i n)
     (setf (elt _projected_gravity i) (sys::peek buf ptr- :float)) (incf ptr- 4)
     ))
   ;; float32[] _base_linear_velocity
   (let (n)
     (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4)
     (setq _base_linear_velocity (instantiate float-vector n))
     (dotimes (i n)
     (setf (elt _base_linear_velocity i) (sys::peek buf ptr- :float)) (incf ptr- 4)
     ))
   ;; float32[] _base_angular_velocity
   (let (n)
     (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4)
     (setq _base_angular_velocity (instantiate float-vector n))
     (dotimes (i n)
     (setf (elt _base_angular_velocity i) (sys::peek buf ptr- :float)) (incf ptr- 4)
     ))
   ;; float32[] _last_loco_action
   (let (n)
     (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4)
     (setq _last_loco_action (instantiate float-vector n))
     (dotimes (i n)
     (setf (elt _last_loco_action i) (sys::peek buf ptr- :float)) (incf ptr- 4)
     ))
   ;; float32[] _last_nav_command
   (let (n)
     (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4)
     (setq _last_nav_command (instantiate float-vector n))
     (dotimes (i n)
     (setf (elt _last_nav_command i) (sys::peek buf ptr- :float)) (incf ptr- 4)
     ))
   ;; bool _standing
     (setq _standing (not (= 0 (sys::peek buf ptr- :char)))) (incf ptr- 1)
   ;; bool _enabled
     (setq _enabled (not (= 0 (sys::peek buf ptr- :char)))) (incf ptr- 1)
   ;;
   self)
  )

(setf (get seanav_deploy_ros1::Lite3State :md5sum-) "1b2609ff74ec6e6dc6fcf2b856840202")
(setf (get seanav_deploy_ros1::Lite3State :datatype-) "seanav_deploy_ros1/Lite3State")
(setf (get seanav_deploy_ros1::Lite3State :definition-)
      "std_msgs/Header header

# Joint order must match the Lite3 training order:
# FL_HipX, FL_HipY, FL_Knee, FR_HipX, FR_HipY, FR_Knee,
# HL_HipX, HL_HipY, HL_Knee, HR_HipX, HR_HipY, HR_Knee.
string[] joint_names
float32[] joint_position
float32[] joint_velocity
float32[] joint_torque

# All vectors are in the robot base frame. Each array has length 3.
float32[] projected_gravity
float32[] base_linear_velocity
float32[] base_angular_velocity

# Last 12-D locomotion action and last 3-D navigation command.
float32[] last_loco_action
float32[] last_nav_command

# TCP bridge: standing in RLControl or Navigation; enabled only in Navigation.
bool standing
bool enabled

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



(provide :seanav_deploy_ros1/Lite3State "1b2609ff74ec6e6dc6fcf2b856840202")


