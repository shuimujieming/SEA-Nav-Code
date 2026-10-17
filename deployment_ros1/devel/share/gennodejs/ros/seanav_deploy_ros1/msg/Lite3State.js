// Auto-generated. Do not edit!

// (in-package seanav_deploy_ros1.msg)


"use strict";

const _serializer = _ros_msg_utils.Serialize;
const _arraySerializer = _serializer.Array;
const _deserializer = _ros_msg_utils.Deserialize;
const _arrayDeserializer = _deserializer.Array;
const _finder = _ros_msg_utils.Find;
const _getByteLength = _ros_msg_utils.getByteLength;
let std_msgs = _finder('std_msgs');

//-----------------------------------------------------------

class Lite3State {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.header = null;
      this.joint_names = null;
      this.joint_position = null;
      this.joint_velocity = null;
      this.joint_torque = null;
      this.projected_gravity = null;
      this.base_linear_velocity = null;
      this.base_angular_velocity = null;
      this.last_loco_action = null;
      this.last_nav_command = null;
      this.standing = null;
      this.enabled = null;
    }
    else {
      if (initObj.hasOwnProperty('header')) {
        this.header = initObj.header
      }
      else {
        this.header = new std_msgs.msg.Header();
      }
      if (initObj.hasOwnProperty('joint_names')) {
        this.joint_names = initObj.joint_names
      }
      else {
        this.joint_names = [];
      }
      if (initObj.hasOwnProperty('joint_position')) {
        this.joint_position = initObj.joint_position
      }
      else {
        this.joint_position = [];
      }
      if (initObj.hasOwnProperty('joint_velocity')) {
        this.joint_velocity = initObj.joint_velocity
      }
      else {
        this.joint_velocity = [];
      }
      if (initObj.hasOwnProperty('joint_torque')) {
        this.joint_torque = initObj.joint_torque
      }
      else {
        this.joint_torque = [];
      }
      if (initObj.hasOwnProperty('projected_gravity')) {
        this.projected_gravity = initObj.projected_gravity
      }
      else {
        this.projected_gravity = [];
      }
      if (initObj.hasOwnProperty('base_linear_velocity')) {
        this.base_linear_velocity = initObj.base_linear_velocity
      }
      else {
        this.base_linear_velocity = [];
      }
      if (initObj.hasOwnProperty('base_angular_velocity')) {
        this.base_angular_velocity = initObj.base_angular_velocity
      }
      else {
        this.base_angular_velocity = [];
      }
      if (initObj.hasOwnProperty('last_loco_action')) {
        this.last_loco_action = initObj.last_loco_action
      }
      else {
        this.last_loco_action = [];
      }
      if (initObj.hasOwnProperty('last_nav_command')) {
        this.last_nav_command = initObj.last_nav_command
      }
      else {
        this.last_nav_command = [];
      }
      if (initObj.hasOwnProperty('standing')) {
        this.standing = initObj.standing
      }
      else {
        this.standing = false;
      }
      if (initObj.hasOwnProperty('enabled')) {
        this.enabled = initObj.enabled
      }
      else {
        this.enabled = false;
      }
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type Lite3State
    // Serialize message field [header]
    bufferOffset = std_msgs.msg.Header.serialize(obj.header, buffer, bufferOffset);
    // Serialize message field [joint_names]
    bufferOffset = _arraySerializer.string(obj.joint_names, buffer, bufferOffset, null);
    // Serialize message field [joint_position]
    bufferOffset = _arraySerializer.float32(obj.joint_position, buffer, bufferOffset, null);
    // Serialize message field [joint_velocity]
    bufferOffset = _arraySerializer.float32(obj.joint_velocity, buffer, bufferOffset, null);
    // Serialize message field [joint_torque]
    bufferOffset = _arraySerializer.float32(obj.joint_torque, buffer, bufferOffset, null);
    // Serialize message field [projected_gravity]
    bufferOffset = _arraySerializer.float32(obj.projected_gravity, buffer, bufferOffset, null);
    // Serialize message field [base_linear_velocity]
    bufferOffset = _arraySerializer.float32(obj.base_linear_velocity, buffer, bufferOffset, null);
    // Serialize message field [base_angular_velocity]
    bufferOffset = _arraySerializer.float32(obj.base_angular_velocity, buffer, bufferOffset, null);
    // Serialize message field [last_loco_action]
    bufferOffset = _arraySerializer.float32(obj.last_loco_action, buffer, bufferOffset, null);
    // Serialize message field [last_nav_command]
    bufferOffset = _arraySerializer.float32(obj.last_nav_command, buffer, bufferOffset, null);
    // Serialize message field [standing]
    bufferOffset = _serializer.bool(obj.standing, buffer, bufferOffset);
    // Serialize message field [enabled]
    bufferOffset = _serializer.bool(obj.enabled, buffer, bufferOffset);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type Lite3State
    let len;
    let data = new Lite3State(null);
    // Deserialize message field [header]
    data.header = std_msgs.msg.Header.deserialize(buffer, bufferOffset);
    // Deserialize message field [joint_names]
    data.joint_names = _arrayDeserializer.string(buffer, bufferOffset, null)
    // Deserialize message field [joint_position]
    data.joint_position = _arrayDeserializer.float32(buffer, bufferOffset, null)
    // Deserialize message field [joint_velocity]
    data.joint_velocity = _arrayDeserializer.float32(buffer, bufferOffset, null)
    // Deserialize message field [joint_torque]
    data.joint_torque = _arrayDeserializer.float32(buffer, bufferOffset, null)
    // Deserialize message field [projected_gravity]
    data.projected_gravity = _arrayDeserializer.float32(buffer, bufferOffset, null)
    // Deserialize message field [base_linear_velocity]
    data.base_linear_velocity = _arrayDeserializer.float32(buffer, bufferOffset, null)
    // Deserialize message field [base_angular_velocity]
    data.base_angular_velocity = _arrayDeserializer.float32(buffer, bufferOffset, null)
    // Deserialize message field [last_loco_action]
    data.last_loco_action = _arrayDeserializer.float32(buffer, bufferOffset, null)
    // Deserialize message field [last_nav_command]
    data.last_nav_command = _arrayDeserializer.float32(buffer, bufferOffset, null)
    // Deserialize message field [standing]
    data.standing = _deserializer.bool(buffer, bufferOffset);
    // Deserialize message field [enabled]
    data.enabled = _deserializer.bool(buffer, bufferOffset);
    return data;
  }

  static getMessageSize(object) {
    let length = 0;
    length += std_msgs.msg.Header.getMessageSize(object.header);
    object.joint_names.forEach((val) => {
      length += 4 + _getByteLength(val);
    });
    length += 4 * object.joint_position.length;
    length += 4 * object.joint_velocity.length;
    length += 4 * object.joint_torque.length;
    length += 4 * object.projected_gravity.length;
    length += 4 * object.base_linear_velocity.length;
    length += 4 * object.base_angular_velocity.length;
    length += 4 * object.last_loco_action.length;
    length += 4 * object.last_nav_command.length;
    return length + 38;
  }

  static datatype() {
    // Returns string type for a message object
    return 'seanav_deploy_ros1/Lite3State';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return '1b2609ff74ec6e6dc6fcf2b856840202';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    std_msgs/Header header
    
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
    
    `;
  }

  static Resolve(msg) {
    // deep-construct a valid message object instance of whatever was passed in
    if (typeof msg !== 'object' || msg === null) {
      msg = {};
    }
    const resolved = new Lite3State(null);
    if (msg.header !== undefined) {
      resolved.header = std_msgs.msg.Header.Resolve(msg.header)
    }
    else {
      resolved.header = new std_msgs.msg.Header()
    }

    if (msg.joint_names !== undefined) {
      resolved.joint_names = msg.joint_names;
    }
    else {
      resolved.joint_names = []
    }

    if (msg.joint_position !== undefined) {
      resolved.joint_position = msg.joint_position;
    }
    else {
      resolved.joint_position = []
    }

    if (msg.joint_velocity !== undefined) {
      resolved.joint_velocity = msg.joint_velocity;
    }
    else {
      resolved.joint_velocity = []
    }

    if (msg.joint_torque !== undefined) {
      resolved.joint_torque = msg.joint_torque;
    }
    else {
      resolved.joint_torque = []
    }

    if (msg.projected_gravity !== undefined) {
      resolved.projected_gravity = msg.projected_gravity;
    }
    else {
      resolved.projected_gravity = []
    }

    if (msg.base_linear_velocity !== undefined) {
      resolved.base_linear_velocity = msg.base_linear_velocity;
    }
    else {
      resolved.base_linear_velocity = []
    }

    if (msg.base_angular_velocity !== undefined) {
      resolved.base_angular_velocity = msg.base_angular_velocity;
    }
    else {
      resolved.base_angular_velocity = []
    }

    if (msg.last_loco_action !== undefined) {
      resolved.last_loco_action = msg.last_loco_action;
    }
    else {
      resolved.last_loco_action = []
    }

    if (msg.last_nav_command !== undefined) {
      resolved.last_nav_command = msg.last_nav_command;
    }
    else {
      resolved.last_nav_command = []
    }

    if (msg.standing !== undefined) {
      resolved.standing = msg.standing;
    }
    else {
      resolved.standing = false
    }

    if (msg.enabled !== undefined) {
      resolved.enabled = msg.enabled;
    }
    else {
      resolved.enabled = false
    }

    return resolved;
    }
};

module.exports = Lite3State;
