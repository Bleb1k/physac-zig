// physac-zig (c) Victor Masnikov 2025

const ph = @import("physac.zig");

pub extern "c" fn InitPhysics() void;
pub extern "c" fn RunPhysicsStep() void;
pub extern "c" fn SetPhysicsTimeStep(delta: f64) void;
pub extern "c" fn IsPhysicsEnabled() bool;
pub extern "c" fn SetPhysicsGravity(x: f32, y: f32) void;
pub extern "c" fn CreatePhysicsBodyCircle(pos: ph.Vector2, radius: f32, density: f32) *ph.PhysicsBody;
pub extern "c" fn CreatePhysicsBodyRectangle(pos: ph.Vector2, width: f32, height: f32, density: f32) *ph.PhysicsBody;
pub extern "c" fn CreatePhysicsBodyPolygon(pos: ph.Vector2, radius: f32, sides: c_int, density: f32) *ph.PhysicsBody;
pub extern "c" fn PhysicsAddForce(body: *ph.PhysicsBody, force: ph.Vector2) void;
pub extern "c" fn PhysicsAddTorque(body: *ph.PhysicsBody, amount: f32) void;
pub extern "c" fn PhysicsShatter(body: *ph.PhysicsBody, position: ph.Vector2, force: f32) void;
pub extern "c" fn GetPhysicsBodiesCount() c_int;
pub extern "c" fn GetPhysicsBody(index: c_int) *ph.PhysicsBody;
pub extern "c" fn GetPhysicsShapeType(index: c_int) c_int;
pub extern "c" fn GetPhysicsShapeVerticesCount(index: c_int) c_int;
pub extern "c" fn GetPhysicsShapeVertex(body: *ph.PhysicsBody, vertex: c_int) ph.Vector2;
pub extern "c" fn SetPhysicsBodyRotation(body: *ph.PhysicsBody, radians: f32) void;
pub extern "c" fn DestroyPhysicsBody(body: *ph.PhysicsBody) void;
pub extern "c" fn ClosePhysics() void;
