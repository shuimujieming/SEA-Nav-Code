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

class SeaNavObservation {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.header = null;
      this.history_length = null;
      this.step_size = null;
      this.observation = null;
      this.proprioception = null;
      this.rays_m = null;
      this.rays_log2 = null;
      this.goal_local = null;
      this.previous_nav_command = null;
      this.valid = null;
    }
    else {
      if (initObj.hasOwnProperty('header')) {
        this.header = initObj.header
      }
      else {
        this.header = new std_msgs.msg.Header();
      }
      if (initObj.hasOwnProperty('history_length')) {
        this.history_length = initObj.history_length
      }
      else {
        this.history_length = 0;
      }
      if (initObj.hasOwnProperty('step_size')) {
        this.step_size = initObj.step_size
      }
      else {
        this.step_size = 0;
      }
      if (initObj.hasOwnProperty('observation')) {
        this.observation = initObj.observation
      }
      else {
        this.observation = [];
      }
      if (initObj.hasOwnProperty('proprioception')) {
        this.proprioception = initObj.proprioception
      }
      else {
        this.proprioception = [];
      }
      if (initObj.hasOwnProperty('rays_m')) {
        this.rays_m = initObj.rays_m
      }
      else {
        this.rays_m = [];
      }
      if (initObj.hasOwnProperty('rays_log2')) {
        this.rays_log2 = initObj.rays_log2
      }
      else {
        this.rays_log2 = [];
      }
      if (initObj.hasOwnProperty('goal_local')) {
        this.goal_local = initObj.goal_local
      }
      else {
        this.goal_local = [];
      }
      if (initObj.hasOwnProperty('previous_nav_command')) {
        this.previous_nav_command = initObj.previous_nav_command
      }
      else {
        this.previous_nav_command = [];
      }
      if (initObj.hasOwnProperty('valid')) {
        this.valid = initObj.valid
      }
      else {
        this.valid = false;
      }
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type SeaNavObservation
    // Serialize message field [header]
    bufferOffset = std_msgs.msg.Header.serialize(obj.header, buffer, bufferOffset);
    // Serialize message field [history_length]
    bufferOffset = _serializer.uint32(obj.history_length, buffer, bufferOffset);
    // Serialize message field [step_size]
    bufferOffset = _serializer.uint32(obj.step_size, buffer, bufferOffset);
    // Serialize message field [observation]
    bufferOffset = _arraySerializer.float32(obj.observation, buffer, bufferOffset, null);
    // Serialize message field [proprioception]
    bufferOffset = _arraySerializer.float32(obj.proprioception, buffer, bufferOffset, null);
    // Serialize message field [rays_m]
    bufferOffset = _arraySerializer.float32(obj.rays_m, buffer, bufferOffset, null);
    // Serialize message field [rays_log2]
    bufferOffset = _arraySerializer.float32(obj.rays_log2, buffer, bufferOffset, null);
    // Serialize message field [goal_local]
    bufferOffset = _arraySerializer.float32(obj.goal_local, buffer, bufferOffset, null);
    // Serialize message field [previous_nav_command]
    bufferOffset = _arraySerializer.float32(obj.previous_nav_command, buffer, bufferOffset, null);
    // Serialize message field [valid]
    bufferOffset = _serializer.bool(obj.valid, buffer, bufferOffset);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type SeaNavObservation
    let len;
    let data = new SeaNavObservation(null);
    // Deserialize message field [header]
    data.header = std_msgs.msg.Header.deserialize(buffer, bufferOffset);
    // Deserialize message field [history_length]
    data.history_length = _deserializer.uint32(buffer, bufferOffset);
    // Deserialize message field [step_size]
    data.step_size = _deserializer.uint32(buffer, bufferOffset);
    // Deserialize message field [observation]
    data.observation = _arrayDeserializer.float32(buffer, bufferOffset, null)
    // Deserialize message field [proprioception]
    data.proprioception = _arrayDeserializer.float32(buffer, bufferOffset, null)
    // Deserialize message field [rays_m]
    data.rays_m = _arrayDeserializer.float32(buffer, bufferOffset, null)
    // Deserialize message field [rays_log2]
    data.rays_log2 = _arrayDeserializer.float32(buffer, bufferOffset, null)
    // Deserialize message field [goal_local]
    data.goal_local = _arrayDeserializer.float32(buffer, bufferOffset, null)
    // Deserialize message field [previous_nav_command]
    data.previous_nav_command = _arrayDeserializer.float32(buffer, bufferOffset, null)
    // Deserialize message field [valid]
    data.valid = _deserializer.bool(buffer, bufferOffset);
    return data;
  }

  static getMessageSize(object) {
    let length = 0;
    length += std_msgs.msg.Header.getMessageSize(object.header);
    length += 4 * object.observation.length;
    length += 4 * object.proprioception.length;
    length += 4 * object.rays_m.length;
    length += 4 * object.rays_log2.length;
    length += 4 * object.goal_local.length;
    length += 4 * object.previous_nav_command.length;
    return length + 33;
  }

  static datatype() {
    // Returns string type for a message object
    return 'seanav_deploy_ros1/SeaNavObservation';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return '49556c39313f8db6d5691b565aef1b41';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    std_msgs/Header header
    
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
    
    `;
  }

  static Resolve(msg) {
    // deep-construct a valid message object instance of whatever was passed in
    if (typeof msg !== 'object' || msg === null) {
      msg = {};
    }
    const resolved = new SeaNavObservation(null);
    if (msg.header !== undefined) {
      resolved.header = std_msgs.msg.Header.Resolve(msg.header)
    }
    else {
      resolved.header = new std_msgs.msg.Header()
    }

    if (msg.history_length !== undefined) {
      resolved.history_length = msg.history_length;
    }
    else {
      resolved.history_length = 0
    }

    if (msg.step_size !== undefined) {
      resolved.step_size = msg.step_size;
    }
    else {
      resolved.step_size = 0
    }

    if (msg.observation !== undefined) {
      resolved.observation = msg.observation;
    }
    else {
      resolved.observation = []
    }

    if (msg.proprioception !== undefined) {
      resolved.proprioception = msg.proprioception;
    }
    else {
      resolved.proprioception = []
    }

    if (msg.rays_m !== undefined) {
      resolved.rays_m = msg.rays_m;
    }
    else {
      resolved.rays_m = []
    }

    if (msg.rays_log2 !== undefined) {
      resolved.rays_log2 = msg.rays_log2;
    }
    else {
      resolved.rays_log2 = []
    }

    if (msg.goal_local !== undefined) {
      resolved.goal_local = msg.goal_local;
    }
    else {
      resolved.goal_local = []
    }

    if (msg.previous_nav_command !== undefined) {
      resolved.previous_nav_command = msg.previous_nav_command;
    }
    else {
      resolved.previous_nav_command = []
    }

    if (msg.valid !== undefined) {
      resolved.valid = msg.valid;
    }
    else {
      resolved.valid = false
    }

    return resolved;
    }
};

module.exports = SeaNavObservation;
