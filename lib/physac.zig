// physac-zig (c) Victor Masnikov 2025

const std = @import("std");

pub const cdef = @import("physac-ext.zig");

test {
    std.testing.refAllDeclsRecursive(@This());
}

const MAX_BODIES: c_int = 64;
const MAX_MANIFOLDS: c_int = 4096;
const MAX_VERTICES: c_int = 24;
const CIRCLE_VERTICES: c_int = 24;
const FIXED_TIME: f32 = 1 / 60;
const COLLISION_ITERATIONS: c_int = 20;
const PENETRATION_ALLOWANCE: f32 = 0.05;
const PENETRATION_CORRECTION: f32 = 0.4;
const PI: f64 = 3.14159265358979323846;
const DEG2RAD: f64 = PI / 180;

pub const Vector2 = extern struct {
    x: f32,
    y: f32,
};

pub const PhysicsShapeType = enum(c_int) { PHYSICS_CIRCLE, PHYSICS_POLYGON };

/// Mat2 type (used for polygon shape rotation matrix)
pub const Mat2 = extern struct {
    m00: f32,
    m01: f32,
    m10: f32,
    m11: f32,
};

pub const Polygon = extern struct {
    /// Current used vertex and normals count
    vertexCount: c_uint,
    /// Polygon vertex positions vectors
    positions: [MAX_VERTICES]Vector2,
    /// Polygon vertex normals vectors
    normals: [MAX_VERTICES]Vector2,
};

pub const PhysicsShape = extern struct {
    /// Physics shape type (circle or polygon)
    type: PhysicsShapeType,
    /// Shape physics body reference
    body: *PhysicsBody,
    /// Circle shape radius (used for circle shapes)
    radius: f32,
    /// Vertices transform matrix 2x2
    transform: Mat2,
    /// Polygon shape vertices position and normals data (just used for polygon shapes)
    vertexData: Polygon,
};

pub const PhysicsBody = extern struct {
    /// Reference unique identifier
    id: c_uint,
    /// Enabled dynamics state (collisions are calculated anyway)
    enabled: bool,
    /// Physics body shape pivot
    position: Vector2,
    /// Current linear velocity applied to position
    velocity: Vector2,
    /// Current linear force (reset to 0 every step)
    force: Vector2,
    /// Current angular velocity applied to orient
    angularVelocity: f32,
    /// Current angular force (reset to 0 every step)
    torque: f32,
    /// Rotation in radians
    orient: f32,
    /// Moment of inertia
    inertia: f32,
    /// Inverse value of inertia
    inverseInertia: f32,
    /// Physics body mass
    mass: f32,
    /// Inverse value of mass
    inverseMass: f32,
    /// Friction when the body has not movement (0 to 1)
    staticFriction: f32,
    /// Friction when the body has movement (0 to 1)
    dynamicFriction: f32,
    /// Restitution coefficient of the body (0 to 1)
    restitution: f32,
    /// Apply gravity force to dynamics
    useGravity: bool,
    /// Physics grounded on other body state
    isGrounded: bool,
    /// Physics rotation constraint
    freezeOrient: bool,
    /// Physics body shape information (type, radius, vertices, normals)
    shape: PhysicsShape,

    const Self = @This();

    /// Creates a new circle physics body with generic parameters
    pub fn circle(pos: Vector2, radius: f32, density: f32) *PhysicsBody {
        return createPhysicsBodyCircle(pos, radius, density);
    }

    /// Creates a new rectangle physics body with generic parameters
    pub fn rectangle(pos: Vector2, width: f32, height: f32, density: f32) *PhysicsBody {
        return createPhysicsBodyRectangle(pos, width, height, density);
    }

    /// Creates a new polygon physics body with generic parameters
    pub fn polygon(pos: Vector2, radius: f32, sides: i32, density: f32) *PhysicsBody {
        return createPhysicsBodyPolygon(pos, radius, sides, density);
    }

    /// Returns a physics body of the bodies pool at a specific index
    pub fn get(index: i32) *PhysicsBody {
        return getPhysicsBody(index);
    }

    /// Adds a force to a physics body
    pub fn addForce(self: *Self, force: Vector2) void {
        physicsAddForce(self, force);
    }

    /// Adds an angular force to a physics body
    pub fn addTorque(self: *Self, amount: f32) void {
        physicsAddTorque(self, amount);
    }

    /// Shatters a polygon shape physics body to little physics bodies with explosion force
    pub fn shatter(self: *Self, position: Vector2, force: f32) void {
        physicsShatter(self, position, force);
    }

    /// Returns transformed position of a body shape (body position + vertex transformed position)
    pub fn getVertex(self: *Self, vertex: i32) Vector2 {
        return getPhysicsShapeVertex(self, vertex);
    }

    /// Sets physics body shape transform based on radians parameter
    pub fn setRotation(self: *Self, radians: f32) void {
        setPhysicsBodyRotation(self, radians);
    }

    /// Unitializes and destroy a physics body
    pub fn destroy(self: *Self) void {
        destroyPhysicsBody(self);
    }
};

/// Initializes physics values, pointers and creates physics loop thread
pub fn initPhysics() void {
    cdef.InitPhysics();
}

/// Run physics step, to be used if PHYSICS_NO_THREADS is set in your main loop
pub fn runPhysicsStep() void {
    cdef.RunPhysicsStep();
}

/// Sets physics fixed time step in milliseconds. 1.666666 by default
pub fn setPhysicsTimeStep(delta: f64) void {
    cdef.SetPhysicsTimeStep(delta);
}

/// Returns true if physics thread is currently enabled
pub fn isPhysicsEnabled() bool {
    return cdef.IsPhysicsEnabled();
}

/// Sets physics global gravity force
pub fn setPhysicsGravity(x: f32, y: f32) void {
    cdef.SetPhysicsGravity(x, y);
}

/// Creates a new circle physics body with generic parameters
pub fn createPhysicsBodyCircle(pos: Vector2, radius: f32, density: f32) *PhysicsBody {
    return @ptrCast(cdef.CreatePhysicsBodyCircle(pos, radius, density));
}

/// Creates a new rectangle physics body with generic parameters
pub fn createPhysicsBodyRectangle(pos: Vector2, width: f32, height: f32, density: f32) *PhysicsBody {
    return @ptrCast(cdef.CreatePhysicsBodyRectangle(pos, width, height, density));
}

/// Creates a new polygon physics body with generic parameters
pub fn createPhysicsBodyPolygon(pos: Vector2, radius: f32, sides: c_int, density: f32) *PhysicsBody {
    return @ptrCast(cdef.CreatePhysicsBodyPolygon(pos, radius, sides, density));
}

/// Adds a force to a physics body
pub fn physicsAddForce(body: *PhysicsBody, force: Vector2) void {
    cdef.PhysicsAddForce(@ptrCast(body), force);
}

/// Adds an angular force to a physics body
pub fn physicsAddTorque(body: *PhysicsBody, amount: f32) void {
    cdef.PhysicsAddTorque(@ptrCast(body), amount);
}

/// Shatters a polygon shape physics body to little physics bodies with explosion force
pub fn physicsShatter(body: *PhysicsBody, position: Vector2, force: f32) void {
    cdef.PhysicsShatter(@ptrCast(body), position, force);
}

/// Returns the current amount of created physics bodies
pub fn getPhysicsBodiesCount() i32 {
    return cdef.GetPhysicsBodiesCount();
}

/// Returns a physics body of the bodies pool at a specific index
pub fn getPhysicsBody(index: i32) *PhysicsBody {
    return @ptrCast(cdef.GetPhysicsBody(@as(c_int, @intCast(index))));
}

/// Returns the physics body shape type (PHYSICS_CIRCLE or PHYSICS_POLYGON)
pub fn getPhysicsShapeType(index: i32) i32 {
    return cdef.GetPhysicsShapeType(index);
}

/// Returns the amount of vertices of a physics body shape
pub fn getPhysicsShapeVerticesCount(index: i32) i32 {
    return cdef.GetPhysicsShapeVerticesCount(index);
}

/// Returns transformed position of a body shape (body position + vertex transformed position)
pub fn getPhysicsShapeVertex(body: *PhysicsBody, vertex: i32) Vector2 {
    return cdef.GetPhysicsShapeVertex(@ptrCast(body), vertex);
}

/// Sets physics body shape transform based on radians parameter
pub fn setPhysicsBodyRotation(body: *PhysicsBody, radians: f32) void {
    cdef.SetPhysicsBodyRotation(@ptrCast(body), radians);
}

/// Unitializes and destroy a physics body
pub fn destroyPhysicsBody(body: *PhysicsBody) void {
    cdef.DestroyPhysicsBody(@ptrCast(body));
}

/// Unitializes physics pointers and closes physics loop thread
pub fn closePhysics() void {
    cdef.ClosePhysics();
}
