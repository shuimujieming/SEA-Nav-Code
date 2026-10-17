; Auto-generated. Do not edit!


(cl:in-package seanav_deploy_ros1-msg)


;//! \htmlinclude NavCommand.msg.html

(cl:defclass <NavCommand> (roslisp-msg-protocol:ros-message)
  ((header
    :reader header
    :initarg :header
    :type std_msgs-msg:Header
    :initform (cl:make-instance 'std_msgs-msg:Header))
   (vx
    :reader vx
    :initarg :vx
    :type cl:float
    :initform 0.0)
   (vy
    :reader vy
    :initarg :vy
    :type cl:float
    :initform 0.0)
   (vyaw
    :reader vyaw
    :initarg :vyaw
    :type cl:float
    :initform 0.0)
   (enable
    :reader enable
    :initarg :enable
    :type cl:boolean
    :initform cl:nil)
   (emergency_stop
    :reader emergency_stop
    :initarg :emergency_stop
    :type cl:boolean
    :initform cl:nil))
)

(cl:defclass NavCommand (<NavCommand>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <NavCommand>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'NavCommand)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name seanav_deploy_ros1-msg:<NavCommand> is deprecated: use seanav_deploy_ros1-msg:NavCommand instead.")))

(cl:ensure-generic-function 'header-val :lambda-list '(m))
(cl:defmethod header-val ((m <NavCommand>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader seanav_deploy_ros1-msg:header-val is deprecated.  Use seanav_deploy_ros1-msg:header instead.")
  (header m))

(cl:ensure-generic-function 'vx-val :lambda-list '(m))
(cl:defmethod vx-val ((m <NavCommand>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader seanav_deploy_ros1-msg:vx-val is deprecated.  Use seanav_deploy_ros1-msg:vx instead.")
  (vx m))

(cl:ensure-generic-function 'vy-val :lambda-list '(m))
(cl:defmethod vy-val ((m <NavCommand>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader seanav_deploy_ros1-msg:vy-val is deprecated.  Use seanav_deploy_ros1-msg:vy instead.")
  (vy m))

(cl:ensure-generic-function 'vyaw-val :lambda-list '(m))
(cl:defmethod vyaw-val ((m <NavCommand>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader seanav_deploy_ros1-msg:vyaw-val is deprecated.  Use seanav_deploy_ros1-msg:vyaw instead.")
  (vyaw m))

(cl:ensure-generic-function 'enable-val :lambda-list '(m))
(cl:defmethod enable-val ((m <NavCommand>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader seanav_deploy_ros1-msg:enable-val is deprecated.  Use seanav_deploy_ros1-msg:enable instead.")
  (enable m))

(cl:ensure-generic-function 'emergency_stop-val :lambda-list '(m))
(cl:defmethod emergency_stop-val ((m <NavCommand>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader seanav_deploy_ros1-msg:emergency_stop-val is deprecated.  Use seanav_deploy_ros1-msg:emergency_stop instead.")
  (emergency_stop m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <NavCommand>) ostream)
  "Serializes a message object of type '<NavCommand>"
  (roslisp-msg-protocol:serialize (cl:slot-value msg 'header) ostream)
  (cl:let ((bits (roslisp-utils:encode-single-float-bits (cl:slot-value msg 'vx))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream))
  (cl:let ((bits (roslisp-utils:encode-single-float-bits (cl:slot-value msg 'vy))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream))
  (cl:let ((bits (roslisp-utils:encode-single-float-bits (cl:slot-value msg 'vyaw))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream))
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:if (cl:slot-value msg 'enable) 1 0)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:if (cl:slot-value msg 'emergency_stop) 1 0)) ostream)
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <NavCommand>) istream)
  "Deserializes a message object of type '<NavCommand>"
  (roslisp-msg-protocol:deserialize (cl:slot-value msg 'header) istream)
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'vx) (roslisp-utils:decode-single-float-bits bits)))
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'vy) (roslisp-utils:decode-single-float-bits bits)))
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'vyaw) (roslisp-utils:decode-single-float-bits bits)))
    (cl:setf (cl:slot-value msg 'enable) (cl:not (cl:zerop (cl:read-byte istream))))
    (cl:setf (cl:slot-value msg 'emergency_stop) (cl:not (cl:zerop (cl:read-byte istream))))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<NavCommand>)))
  "Returns string type for a message object of type '<NavCommand>"
  "seanav_deploy_ros1/NavCommand")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'NavCommand)))
  "Returns string type for a message object of type 'NavCommand"
  "seanav_deploy_ros1/NavCommand")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<NavCommand>)))
  "Returns md5sum for a message object of type '<NavCommand>"
  "05f25bc177d20bf6832c6a824e16b75b")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'NavCommand)))
  "Returns md5sum for a message object of type 'NavCommand"
  "05f25bc177d20bf6832c6a824e16b75b")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<NavCommand>)))
  "Returns full string definition for message of type '<NavCommand>"
  (cl:format cl:nil "std_msgs/Header header~%~%# Physical command sent to the locomotion layer, not normalized policy output.~%# vx and vy are m/s in base_link; vyaw is rad/s about base_link +Z.~%float32 vx~%float32 vy~%float32 vyaw~%~%bool enable~%bool emergency_stop~%~%================================================================================~%MSG: std_msgs/Header~%# Standard metadata for higher-level stamped data types.~%# This is generally used to communicate timestamped data ~%# in a particular coordinate frame.~%# ~%# sequence ID: consecutively increasing ID ~%uint32 seq~%#Two-integer timestamp that is expressed as:~%# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')~%# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')~%# time-handling sugar is provided by the client library~%time stamp~%#Frame this data is associated with~%string frame_id~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'NavCommand)))
  "Returns full string definition for message of type 'NavCommand"
  (cl:format cl:nil "std_msgs/Header header~%~%# Physical command sent to the locomotion layer, not normalized policy output.~%# vx and vy are m/s in base_link; vyaw is rad/s about base_link +Z.~%float32 vx~%float32 vy~%float32 vyaw~%~%bool enable~%bool emergency_stop~%~%================================================================================~%MSG: std_msgs/Header~%# Standard metadata for higher-level stamped data types.~%# This is generally used to communicate timestamped data ~%# in a particular coordinate frame.~%# ~%# sequence ID: consecutively increasing ID ~%uint32 seq~%#Two-integer timestamp that is expressed as:~%# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')~%# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')~%# time-handling sugar is provided by the client library~%time stamp~%#Frame this data is associated with~%string frame_id~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <NavCommand>))
  (cl:+ 0
     (roslisp-msg-protocol:serialization-length (cl:slot-value msg 'header))
     4
     4
     4
     1
     1
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <NavCommand>))
  "Converts a ROS message object to a list"
  (cl:list 'NavCommand
    (cl:cons ':header (header msg))
    (cl:cons ':vx (vx msg))
    (cl:cons ':vy (vy msg))
    (cl:cons ':vyaw (vyaw msg))
    (cl:cons ':enable (enable msg))
    (cl:cons ':emergency_stop (emergency_stop msg))
))
