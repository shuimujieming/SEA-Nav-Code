;; Auto-generated. Do not edit!


(when (boundp 'seanav_deploy_ros1::NavCommand)
  (if (not (find-package "SEANAV_DEPLOY_ROS1"))
    (make-package "SEANAV_DEPLOY_ROS1"))
  (shadow 'NavCommand (find-package "SEANAV_DEPLOY_ROS1")))
(unless (find-package "SEANAV_DEPLOY_ROS1::NAVCOMMAND")
  (make-package "SEANAV_DEPLOY_ROS1::NAVCOMMAND"))

(in-package "ROS")
;;//! \htmlinclude NavCommand.msg.html
(if (not (find-package "STD_MSGS"))
  (ros::roseus-add-msgs "std_msgs"))


(defclass seanav_deploy_ros1::NavCommand
  :super ros::object
  :slots (_header _vx _vy _vyaw _enable _emergency_stop ))

(defmethod seanav_deploy_ros1::NavCommand
  (:init
   (&key
    ((:header __header) (instance std_msgs::Header :init))
    ((:vx __vx) 0.0)
    ((:vy __vy) 0.0)
    ((:vyaw __vyaw) 0.0)
    ((:enable __enable) nil)
    ((:emergency_stop __emergency_stop) nil)
    )
   (send-super :init)
   (setq _header __header)
   (setq _vx (float __vx))
   (setq _vy (float __vy))
   (setq _vyaw (float __vyaw))
   (setq _enable __enable)
   (setq _emergency_stop __emergency_stop)
   self)
  (:header
   (&rest __header)
   (if (keywordp (car __header))
       (send* _header __header)
     (progn
       (if __header (setq _header (car __header)))
       _header)))
  (:vx
   (&optional __vx)
   (if __vx (setq _vx __vx)) _vx)
  (:vy
   (&optional __vy)
   (if __vy (setq _vy __vy)) _vy)
  (:vyaw
   (&optional __vyaw)
   (if __vyaw (setq _vyaw __vyaw)) _vyaw)
  (:enable
   (&optional (__enable :null))
   (if (not (eq __enable :null)) (setq _enable __enable)) _enable)
  (:emergency_stop
   (&optional (__emergency_stop :null))
   (if (not (eq __emergency_stop :null)) (setq _emergency_stop __emergency_stop)) _emergency_stop)
  (:serialization-length
   ()
   (+
    ;; std_msgs/Header _header
    (send _header :serialization-length)
    ;; float32 _vx
    4
    ;; float32 _vy
    4
    ;; float32 _vyaw
    4
    ;; bool _enable
    1
    ;; bool _emergency_stop
    1
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; std_msgs/Header _header
       (send _header :serialize s)
     ;; float32 _vx
       (sys::poke _vx (send s :buffer) (send s :count) :float) (incf (stream-count s) 4)
     ;; float32 _vy
       (sys::poke _vy (send s :buffer) (send s :count) :float) (incf (stream-count s) 4)
     ;; float32 _vyaw
       (sys::poke _vyaw (send s :buffer) (send s :count) :float) (incf (stream-count s) 4)
     ;; bool _enable
       (if _enable (write-byte -1 s) (write-byte 0 s))
     ;; bool _emergency_stop
       (if _emergency_stop (write-byte -1 s) (write-byte 0 s))
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; std_msgs/Header _header
     (send _header :deserialize buf ptr-) (incf ptr- (send _header :serialization-length))
   ;; float32 _vx
     (setq _vx (sys::peek buf ptr- :float)) (incf ptr- 4)
   ;; float32 _vy
     (setq _vy (sys::peek buf ptr- :float)) (incf ptr- 4)
   ;; float32 _vyaw
     (setq _vyaw (sys::peek buf ptr- :float)) (incf ptr- 4)
   ;; bool _enable
     (setq _enable (not (= 0 (sys::peek buf ptr- :char)))) (incf ptr- 1)
   ;; bool _emergency_stop
     (setq _emergency_stop (not (= 0 (sys::peek buf ptr- :char)))) (incf ptr- 1)
   ;;
   self)
  )

(setf (get seanav_deploy_ros1::NavCommand :md5sum-) "05f25bc177d20bf6832c6a824e16b75b")
(setf (get seanav_deploy_ros1::NavCommand :datatype-) "seanav_deploy_ros1/NavCommand")
(setf (get seanav_deploy_ros1::NavCommand :definition-)
      "std_msgs/Header header

# Physical command sent to the locomotion layer, not normalized policy output.
# vx and vy are m/s in base_link; vyaw is rad/s about base_link +Z.
float32 vx
float32 vy
float32 vyaw

bool enable
bool emergency_stop

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



(provide :seanav_deploy_ros1/NavCommand "05f25bc177d20bf6832c6a824e16b75b")


