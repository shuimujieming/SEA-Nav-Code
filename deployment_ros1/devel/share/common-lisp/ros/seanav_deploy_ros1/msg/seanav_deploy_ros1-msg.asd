
(cl:in-package :asdf)

(defsystem "seanav_deploy_ros1-msg"
  :depends-on (:roslisp-msg-protocol :roslisp-utils :std_msgs-msg
)
  :components ((:file "_package")
    (:file "JointCommand" :depends-on ("_package_JointCommand"))
    (:file "_package_JointCommand" :depends-on ("_package"))
    (:file "Lite3State" :depends-on ("_package_Lite3State"))
    (:file "_package_Lite3State" :depends-on ("_package"))
    (:file "NavCommand" :depends-on ("_package_NavCommand"))
    (:file "_package_NavCommand" :depends-on ("_package"))
    (:file "SeaNavObservation" :depends-on ("_package_SeaNavObservation"))
    (:file "_package_SeaNavObservation" :depends-on ("_package"))
  ))