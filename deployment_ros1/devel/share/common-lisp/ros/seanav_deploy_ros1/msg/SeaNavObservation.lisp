; Auto-generated. Do not edit!


(cl:in-package seanav_deploy_ros1-msg)


;//! \htmlinclude SeaNavObservation.msg.html

(cl:defclass <SeaNavObservation> (roslisp-msg-protocol:ros-message)
  ((header
    :reader header
    :initarg :header
    :type std_msgs-msg:Header
    :initform (cl:make-instance 'std_msgs-msg:Header))
   (history_length
    :reader history_length
    :initarg :history_length
    :type cl:integer
    :initform 0)
   (step_size
    :reader step_size
    :initarg :step_size
    :type cl:integer
    :initform 0)
   (observation
    :reader observation
    :initarg :observation
    :type (cl:vector cl:float)
   :initform (cl:make-array 0 :element-type 'cl:float :initial-element 0.0))
   (proprioception
    :reader proprioception
    :initarg :proprioception
    :type (cl:vector cl:float)
   :initform (cl:make-array 0 :element-type 'cl:float :initial-element 0.0))
   (rays_m
    :reader rays_m
    :initarg :rays_m
    :type (cl:vector cl:float)
   :initform (cl:make-array 0 :element-type 'cl:float :initial-element 0.0))
   (rays_log2
    :reader rays_log2
    :initarg :rays_log2
    :type (cl:vector cl:float)
   :initform (cl:make-array 0 :element-type 'cl:float :initial-element 0.0))
   (goal_local
    :reader goal_local
    :initarg :goal_local
    :type (cl:vector cl:float)
   :initform (cl:make-array 0 :element-type 'cl:float :initial-element 0.0))
   (previous_nav_command
    :reader previous_nav_command
    :initarg :previous_nav_command
    :type (cl:vector cl:float)
   :initform (cl:make-array 0 :element-type 'cl:float :initial-element 0.0))
   (valid
    :reader valid
    :initarg :valid
    :type cl:boolean
    :initform cl:nil))
)

(cl:defclass SeaNavObservation (<SeaNavObservation>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <SeaNavObservation>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'SeaNavObservation)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name seanav_deploy_ros1-msg:<SeaNavObservation> is deprecated: use seanav_deploy_ros1-msg:SeaNavObservation instead.")))

(cl:ensure-generic-function 'header-val :lambda-list '(m))
(cl:defmethod header-val ((m <SeaNavObservation>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader seanav_deploy_ros1-msg:header-val is deprecated.  Use seanav_deploy_ros1-msg:header instead.")
  (header m))

(cl:ensure-generic-function 'history_length-val :lambda-list '(m))
(cl:defmethod history_length-val ((m <SeaNavObservation>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader seanav_deploy_ros1-msg:history_length-val is deprecated.  Use seanav_deploy_ros1-msg:history_length instead.")
  (history_length m))

(cl:ensure-generic-function 'step_size-val :lambda-list '(m))
(cl:defmethod step_size-val ((m <SeaNavObservation>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader seanav_deploy_ros1-msg:step_size-val is deprecated.  Use seanav_deploy_ros1-msg:step_size instead.")
  (step_size m))

(cl:ensure-generic-function 'observation-val :lambda-list '(m))
(cl:defmethod observation-val ((m <SeaNavObservation>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader seanav_deploy_ros1-msg:observation-val is deprecated.  Use seanav_deploy_ros1-msg:observation instead.")
  (observation m))

(cl:ensure-generic-function 'proprioception-val :lambda-list '(m))
(cl:defmethod proprioception-val ((m <SeaNavObservation>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader seanav_deploy_ros1-msg:proprioception-val is deprecated.  Use seanav_deploy_ros1-msg:proprioception instead.")
  (proprioception m))

(cl:ensure-generic-function 'rays_m-val :lambda-list '(m))
(cl:defmethod rays_m-val ((m <SeaNavObservation>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader seanav_deploy_ros1-msg:rays_m-val is deprecated.  Use seanav_deploy_ros1-msg:rays_m instead.")
  (rays_m m))

(cl:ensure-generic-function 'rays_log2-val :lambda-list '(m))
(cl:defmethod rays_log2-val ((m <SeaNavObservation>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader seanav_deploy_ros1-msg:rays_log2-val is deprecated.  Use seanav_deploy_ros1-msg:rays_log2 instead.")
  (rays_log2 m))

(cl:ensure-generic-function 'goal_local-val :lambda-list '(m))
(cl:defmethod goal_local-val ((m <SeaNavObservation>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader seanav_deploy_ros1-msg:goal_local-val is deprecated.  Use seanav_deploy_ros1-msg:goal_local instead.")
  (goal_local m))

(cl:ensure-generic-function 'previous_nav_command-val :lambda-list '(m))
(cl:defmethod previous_nav_command-val ((m <SeaNavObservation>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader seanav_deploy_ros1-msg:previous_nav_command-val is deprecated.  Use seanav_deploy_ros1-msg:previous_nav_command instead.")
  (previous_nav_command m))

(cl:ensure-generic-function 'valid-val :lambda-list '(m))
(cl:defmethod valid-val ((m <SeaNavObservation>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader seanav_deploy_ros1-msg:valid-val is deprecated.  Use seanav_deploy_ros1-msg:valid instead.")
  (valid m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <SeaNavObservation>) ostream)
  "Serializes a message object of type '<SeaNavObservation>"
  (roslisp-msg-protocol:serialize (cl:slot-value msg 'header) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'history_length)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 8) (cl:slot-value msg 'history_length)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 16) (cl:slot-value msg 'history_length)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 24) (cl:slot-value msg 'history_length)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'step_size)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 8) (cl:slot-value msg 'step_size)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 16) (cl:slot-value msg 'step_size)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 24) (cl:slot-value msg 'step_size)) ostream)
  (cl:let ((__ros_arr_len (cl:length (cl:slot-value msg 'observation))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_arr_len) ostream))
  (cl:map cl:nil #'(cl:lambda (ele) (cl:let ((bits (roslisp-utils:encode-single-float-bits ele)))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream)))
   (cl:slot-value msg 'observation))
  (cl:let ((__ros_arr_len (cl:length (cl:slot-value msg 'proprioception))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_arr_len) ostream))
  (cl:map cl:nil #'(cl:lambda (ele) (cl:let ((bits (roslisp-utils:encode-single-float-bits ele)))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream)))
   (cl:slot-value msg 'proprioception))
  (cl:let ((__ros_arr_len (cl:length (cl:slot-value msg 'rays_m))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_arr_len) ostream))
  (cl:map cl:nil #'(cl:lambda (ele) (cl:let ((bits (roslisp-utils:encode-single-float-bits ele)))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream)))
   (cl:slot-value msg 'rays_m))
  (cl:let ((__ros_arr_len (cl:length (cl:slot-value msg 'rays_log2))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_arr_len) ostream))
  (cl:map cl:nil #'(cl:lambda (ele) (cl:let ((bits (roslisp-utils:encode-single-float-bits ele)))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream)))
   (cl:slot-value msg 'rays_log2))
  (cl:let ((__ros_arr_len (cl:length (cl:slot-value msg 'goal_local))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_arr_len) ostream))
  (cl:map cl:nil #'(cl:lambda (ele) (cl:let ((bits (roslisp-utils:encode-single-float-bits ele)))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream)))
   (cl:slot-value msg 'goal_local))
  (cl:let ((__ros_arr_len (cl:length (cl:slot-value msg 'previous_nav_command))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_arr_len) ostream))
  (cl:map cl:nil #'(cl:lambda (ele) (cl:let ((bits (roslisp-utils:encode-single-float-bits ele)))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream)))
   (cl:slot-value msg 'previous_nav_command))
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:if (cl:slot-value msg 'valid) 1 0)) ostream)
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <SeaNavObservation>) istream)
  "Deserializes a message object of type '<SeaNavObservation>"
  (roslisp-msg-protocol:deserialize (cl:slot-value msg 'header) istream)
    (cl:setf (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'history_length)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 8) (cl:slot-value msg 'history_length)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 16) (cl:slot-value msg 'history_length)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 24) (cl:slot-value msg 'history_length)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'step_size)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 8) (cl:slot-value msg 'step_size)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 16) (cl:slot-value msg 'step_size)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 24) (cl:slot-value msg 'step_size)) (cl:read-byte istream))
  (cl:let ((__ros_arr_len 0))
    (cl:setf (cl:ldb (cl:byte 8 0) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 8) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 16) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 24) __ros_arr_len) (cl:read-byte istream))
  (cl:setf (cl:slot-value msg 'observation) (cl:make-array __ros_arr_len))
  (cl:let ((vals (cl:slot-value msg 'observation)))
    (cl:dotimes (i __ros_arr_len)
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
    (cl:setf (cl:aref vals i) (roslisp-utils:decode-single-float-bits bits))))))
  (cl:let ((__ros_arr_len 0))
    (cl:setf (cl:ldb (cl:byte 8 0) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 8) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 16) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 24) __ros_arr_len) (cl:read-byte istream))
  (cl:setf (cl:slot-value msg 'proprioception) (cl:make-array __ros_arr_len))
  (cl:let ((vals (cl:slot-value msg 'proprioception)))
    (cl:dotimes (i __ros_arr_len)
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
    (cl:setf (cl:aref vals i) (roslisp-utils:decode-single-float-bits bits))))))
  (cl:let ((__ros_arr_len 0))
    (cl:setf (cl:ldb (cl:byte 8 0) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 8) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 16) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 24) __ros_arr_len) (cl:read-byte istream))
  (cl:setf (cl:slot-value msg 'rays_m) (cl:make-array __ros_arr_len))
  (cl:let ((vals (cl:slot-value msg 'rays_m)))
    (cl:dotimes (i __ros_arr_len)
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
    (cl:setf (cl:aref vals i) (roslisp-utils:decode-single-float-bits bits))))))
  (cl:let ((__ros_arr_len 0))
    (cl:setf (cl:ldb (cl:byte 8 0) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 8) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 16) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 24) __ros_arr_len) (cl:read-byte istream))
  (cl:setf (cl:slot-value msg 'rays_log2) (cl:make-array __ros_arr_len))
  (cl:let ((vals (cl:slot-value msg 'rays_log2)))
    (cl:dotimes (i __ros_arr_len)
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
    (cl:setf (cl:aref vals i) (roslisp-utils:decode-single-float-bits bits))))))
  (cl:let ((__ros_arr_len 0))
    (cl:setf (cl:ldb (cl:byte 8 0) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 8) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 16) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 24) __ros_arr_len) (cl:read-byte istream))
  (cl:setf (cl:slot-value msg 'goal_local) (cl:make-array __ros_arr_len))
  (cl:let ((vals (cl:slot-value msg 'goal_local)))
    (cl:dotimes (i __ros_arr_len)
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
    (cl:setf (cl:aref vals i) (roslisp-utils:decode-single-float-bits bits))))))
  (cl:let ((__ros_arr_len 0))
    (cl:setf (cl:ldb (cl:byte 8 0) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 8) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 16) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 24) __ros_arr_len) (cl:read-byte istream))
  (cl:setf (cl:slot-value msg 'previous_nav_command) (cl:make-array __ros_arr_len))
  (cl:let ((vals (cl:slot-value msg 'previous_nav_command)))
    (cl:dotimes (i __ros_arr_len)
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
    (cl:setf (cl:aref vals i) (roslisp-utils:decode-single-float-bits bits))))))
    (cl:setf (cl:slot-value msg 'valid) (cl:not (cl:zerop (cl:read-byte istream))))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<SeaNavObservation>)))
  "Returns string type for a message object of type '<SeaNavObservation>"
  "seanav_deploy_ros1/SeaNavObservation")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'SeaNavObservation)))
  "Returns string type for a message object of type 'SeaNavObservation"
  "seanav_deploy_ros1/SeaNavObservation")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<SeaNavObservation>)))
  "Returns md5sum for a message object of type '<SeaNavObservation>"
  "49556c39313f8db6d5691b565aef1b41")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'SeaNavObservation)))
  "Returns md5sum for a message object of type 'SeaNavObservation"
  "49556c39313f8db6d5691b565aef1b41")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<SeaNavObservation>)))
  "Returns full string definition for message of type '<SeaNavObservation>"
  (cl:format cl:nil "std_msgs/Header header~%~%# One step is 55 values; history is oldest-to-newest and flattened.~%# [gravity(3), previous_nav_command(3), body_lin_vel(3), body_ang_vel(3),~%#  log2(rays_m)(41), goal_local_xy(2)] repeated history_length times.~%uint32 history_length~%uint32 step_size~%float32[] observation~%~%# Current unflattened values are included for inspection and debugging.~%float32[] proprioception~%float32[] rays_m~%float32[] rays_log2~%# Last accepted target in body XY, available with a fresh pose even if valid=false.~%# Empty until a target is set, or when pose is missing/stale.~%float32[] goal_local~%float32[] previous_nav_command~%~%bool valid~%~%================================================================================~%MSG: std_msgs/Header~%# Standard metadata for higher-level stamped data types.~%# This is generally used to communicate timestamped data ~%# in a particular coordinate frame.~%# ~%# sequence ID: consecutively increasing ID ~%uint32 seq~%#Two-integer timestamp that is expressed as:~%# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')~%# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')~%# time-handling sugar is provided by the client library~%time stamp~%#Frame this data is associated with~%string frame_id~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'SeaNavObservation)))
  "Returns full string definition for message of type 'SeaNavObservation"
  (cl:format cl:nil "std_msgs/Header header~%~%# One step is 55 values; history is oldest-to-newest and flattened.~%# [gravity(3), previous_nav_command(3), body_lin_vel(3), body_ang_vel(3),~%#  log2(rays_m)(41), goal_local_xy(2)] repeated history_length times.~%uint32 history_length~%uint32 step_size~%float32[] observation~%~%# Current unflattened values are included for inspection and debugging.~%float32[] proprioception~%float32[] rays_m~%float32[] rays_log2~%# Last accepted target in body XY, available with a fresh pose even if valid=false.~%# Empty until a target is set, or when pose is missing/stale.~%float32[] goal_local~%float32[] previous_nav_command~%~%bool valid~%~%================================================================================~%MSG: std_msgs/Header~%# Standard metadata for higher-level stamped data types.~%# This is generally used to communicate timestamped data ~%# in a particular coordinate frame.~%# ~%# sequence ID: consecutively increasing ID ~%uint32 seq~%#Two-integer timestamp that is expressed as:~%# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')~%# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')~%# time-handling sugar is provided by the client library~%time stamp~%#Frame this data is associated with~%string frame_id~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <SeaNavObservation>))
  (cl:+ 0
     (roslisp-msg-protocol:serialization-length (cl:slot-value msg 'header))
     4
     4
     4 (cl:reduce #'cl:+ (cl:slot-value msg 'observation) :key #'(cl:lambda (ele) (cl:declare (cl:ignorable ele)) (cl:+ 4)))
     4 (cl:reduce #'cl:+ (cl:slot-value msg 'proprioception) :key #'(cl:lambda (ele) (cl:declare (cl:ignorable ele)) (cl:+ 4)))
     4 (cl:reduce #'cl:+ (cl:slot-value msg 'rays_m) :key #'(cl:lambda (ele) (cl:declare (cl:ignorable ele)) (cl:+ 4)))
     4 (cl:reduce #'cl:+ (cl:slot-value msg 'rays_log2) :key #'(cl:lambda (ele) (cl:declare (cl:ignorable ele)) (cl:+ 4)))
     4 (cl:reduce #'cl:+ (cl:slot-value msg 'goal_local) :key #'(cl:lambda (ele) (cl:declare (cl:ignorable ele)) (cl:+ 4)))
     4 (cl:reduce #'cl:+ (cl:slot-value msg 'previous_nav_command) :key #'(cl:lambda (ele) (cl:declare (cl:ignorable ele)) (cl:+ 4)))
     1
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <SeaNavObservation>))
  "Converts a ROS message object to a list"
  (cl:list 'SeaNavObservation
    (cl:cons ':header (header msg))
    (cl:cons ':history_length (history_length msg))
    (cl:cons ':step_size (step_size msg))
    (cl:cons ':observation (observation msg))
    (cl:cons ':proprioception (proprioception msg))
    (cl:cons ':rays_m (rays_m msg))
    (cl:cons ':rays_log2 (rays_log2 msg))
    (cl:cons ':goal_local (goal_local msg))
    (cl:cons ':previous_nav_command (previous_nav_command msg))
    (cl:cons ':valid (valid msg))
))
