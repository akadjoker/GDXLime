package com.gdx.math;

/**
 * ...
 * @author Luis Santos AKA DJOKER
 */
int collisionRecursionDepth;

//-----------------------------------------------------------------------------
// Name: GetPosition()
// Desc: Main collision detection function. This is what you call to get
//       a position.
//-----------------------------------------------------------------------------
D3DVECTOR GetPosition(D3DVECTOR pos, D3DVECTOR vel, D3DVECTOR ellipsoidRadius,
		int numFaces, float* verts) {

	TCollisionPacket collisionPackage;

	// Do collision detection:
	collisionPackage.R3Position = pos;
	collisionPackage.R3Velocity = vel;
	collisionPackage.eRadius = ellipsoidRadius;
	// calculate position and velocity in eSpace
	D3DVECTOR eSpacePosition = collisionPackage.R3Position
			/ collisionPackage.eRadius;
	D3DVECTOR eSpaceVelocity = collisionPackage.R3Velocity
			/ collisionPackage.eRadius;
	// Iterate until we have our final position.
	collisionRecursionDepth = 0;
	D3DVECTOR finalPosition = CollideWithWorld(&collisionPackage,
			eSpacePosition, eSpaceVelocity, numFaces, verts);
	finalPosition.x *= ellipsoidRadius.x;
	finalPosition.y *= ellipsoidRadius.y;
	finalPosition.z *= ellipsoidRadius.z;
	return finalPosition;
}

//-----------------------------------------------------------------------------
// Name: collideWithWorld()
// Desc: Recursive part of the collision response. This function is the
//       one who actually calls the collision check on the meshes
//-----------------------------------------------------------------------------
D3DVECTOR CollideWithWorld(TCollisionPacket *collisionPackage, D3DVECTOR pos,
		D3DVECTOR vel, int numFaces, float* verts) {

	// All hard-coded distances in this function is
	// scaled to fit the setting above..
	float veryCloseDistance = 0.005f;
	// do we need to worry?
	if (collisionRecursionDepth > 5)
		return pos;
	// Ok, we need to worry:
	collisionPackage->velocity = vel;
	collisionPackage->normalizedVelocity = vel;
	normalize(collisionPackage->normalizedVelocity);
	collisionPackage->basePoint = pos;
	collisionPackage->foundCollision = false;
	// Check for collision (calls the collision routines)
	// Application specific!!
	CheckCollision(collisionPackage, numFaces, verts);
	// If no collision we just move along the velocity
	if (collisionPackage->foundCollision == false) {
		return pos + vel;
	}
	// *** Collision occured ***
	// The original destination point
	D3DVECTOR destinationPoint = pos + vel;
	D3DVECTOR newBasePoint = pos;
	// only update if we are not already very close
	// and if so we only move very close to intersection..not
	// to the exact spot.
	if (collisionPackage->nearestDistance >= veryCloseDistance) {
		D3DVECTOR V = vel;
		setLength(V, collisionPackage->nearestDistance - veryCloseDistance);
		newBasePoint = collisionPackage->basePoint + V;
		// Adjust polygon intersection point (so sliding
		// plane will be unaffected by the fact that we
		// move slightly less than collision tells us)
		normalize(V);
		collisionPackage->intersectionPoint = collisionPackage->intersectionPoint - (veryCloseDistance * V);
	}
	// Determine the sliding plane
	D3DVECTOR slidePlaneOrigin = collisionPackage->intersectionPoint;
	D3DVECTOR slidePlaneNormal = newBasePoint
			- collisionPackage->intersectionPoint;
	normalize(slidePlaneNormal);
	PLANE slidingPlane(slidePlaneOrigin, slidePlaneNormal);
	// Again, sorry about formatting.. but look carefully ;)
	D3DVECTOR newDestinationPoint = destinationPoint
			- slidingPlane.signedDistanceTo(destinationPoint)
					* slidePlaneNormal;
	// Generate the slide vector, which will become our new
	// velocity vector for the next iteration
	D3DVECTOR newVelocityVector = newDestinationPoint
			- collisionPackage->intersectionPoint;
	// Recurse:
	// dont recurse if the new velocity is very small
	if (length(newVelocityVector) < veryCloseDistance) {
		return newBasePoint;
	}
	collisionRecursionDepth++;
	return CollideWithWorld(collisionPackage, newBasePoint, newVelocityVector,
			numFaces, verts);
}



collision.cpp

void CheckCollision(TCollisionPacket *colPackage, int numFaces, float* verts) {

	//__android_log_print(ANDROID_LOG_DEBUG, "Collision", "CheckCollision");

	// plane data
	D3DVECTOR p1, p2, p3;
	D3DVECTOR eRadius = colPackage->eRadius;

	D3DVECTOR source = colPackage->basePoint;
	D3DVECTOR velocity = colPackage->velocity;
	__android_log_print(ANDROID_LOG_DEBUG, "Collision", "position (scaled) is %f %f %f", source.x, source.y, source.z);
	__android_log_print(ANDROID_LOG_DEBUG, "Collision", "velocity (scaled) is %f %f %f",velocity.x, velocity.y, velocity.z);
	// loop through all faces in mesh
	float sMultx = 1 / eRadius.x;
	float sMulty = 1 / eRadius.y;
	float sMultz = 1 / eRadius.z;

	for (int i = 0; i < numFaces; i++) {
		// Get the data for the triangle in question and scale to ellipsoid space
		// Pull directly out of ordered verts array and convert to floating point for calculations
		int idx = i * 9;
		p1.x = verts[idx] * sMultx;
		p1.y = verts[idx + 1] * sMulty;
		p1.z = verts[idx + 2] * sMultz;

		p2.x = verts[idx + 3] * sMultx;
		p2.y = verts[idx + 4] * sMulty;
		p2.z = verts[idx + 5] * sMultz;

		p3.x = verts[idx + 6] * sMultx;
		p3.y = verts[idx + 7] * sMulty;
		p3.z = verts[idx + 8] * sMultz;

		__android_log_print(ANDROID_LOG_DEBUG, "Collision", "Checking face %f %f %f, %f %f %f, %f %f %f", p1.x, p1.y, p1.z, p2.x, p2.y, p2.z, p3.x, p3.y, p3.z);


		PLANE trianglePlane(p1, p2, p3);

		// Is triangle front-facing to the velocity vector?
		// We only check front-facing triangles
		// (your choice of course)
		if (trianglePlane.isFrontFacingTo(colPackage->normalizedVelocity)) {
			__android_log_print(ANDROID_LOG_DEBUG, "Collision", "Is front facing");
			// Get interval of plane intersection:
			double t0, t1;
			bool embeddedInPlane = false;
			// Calculate the signed distance from sphere
			// position to triangle plane
			double signedDistToTrianglePlane =
					trianglePlane.signedDistanceTo(colPackage->basePoint);
			// cache this as we’re going to use it a few times below:
			float normalDotVelocity = dot(trianglePlane.normal,
					colPackage->velocity);
			// if sphere is travelling parrallel to the plane:
			if (normalDotVelocity == 0.0f) {
				if (fabs(signedDistToTrianglePlane) >= 1.0f) {
					// Sphere is not embedded in plane.
					// No collision possible:
					continue;
				} else {
					// sphere is embedded in plane.
					// It intersects in the whole range [0..1]
					embeddedInPlane = true;
					t0 = 0.0;
					t1 = 1.0;
				}
			} else {
				// N dot D is not 0. Calculate intersection interval:
				t0 = (-1.0 - signedDistToTrianglePlane) / normalDotVelocity;
				t1 = (1.0 - signedDistToTrianglePlane) / normalDotVelocity;
				// Swap so t0 < t1
				if (t0 > t1) {
					double temp = t1;
					t1 = t0;
					t0 = temp;
				}
				// Check that at least one result is within range:
				if (t0 > 1.0f || t1 < 0.0f) {
					// Both t values are outside values [0,1]
					// No collision possible:
					continue;
				}
				// Clamp to [0,1]
				if (t0 < 0.0)
					t0 = 0.0;
				if (t1 < 0.0)
					t1 = 0.0;
				if (t0 > 1.0)
					t0 = 1.0;
				if (t1 > 1.0)
					t1 = 1.0;
			}
			// OK, at this point we have two time values t0 and t1
			// between which the swept sphere intersects with the
			// triangle plane. If any collision is to occur it must
			// happen within this interval.
			D3DVECTOR collisionPoint;
			bool foundCollison = false;
			float t = 1.0;
			// First we check for the easy case - collision inside
			// the triangle. If this happens it must be at time t0
			// as this is when the sphere rests on the front side
			// of the triangle plane. Note, this can only happen if
			// the sphere is not embedded in the triangle plane.

			if (!embeddedInPlane) {
				D3DVECTOR planeIntersectionPoint = (colPackage->basePoint
						- trianglePlane.normal) + t0 * colPackage->velocity;
				if (checkPointInTriangle(planeIntersectionPoint, p1, p2, p3)) {
					foundCollison = true;
					t = t0;
					collisionPoint = planeIntersectionPoint;
				}
			}
			// if we haven’t found a collision already we’ll have to
			// sweep sphere against points and edges of the triangle.
			// Note: A collision inside the triangle (the check above)
			// will always happen before a vertex or edge collision!
			// This is why we can skip the swept test if the above
			// gives a collision!
			if (foundCollison == false) {
				// some commonly used terms:
				D3DVECTOR velocity = colPackage->velocity;
				D3DVECTOR base = colPackage->basePoint;
				float velocitySquaredLength = squaredLength(velocity);
				float a, b, c; // Params for equation
				float newT;
				// For each vertex or edge a quadratic equation have to
				// be solved. We parameterize this equation as
				// a*t^2 + b*t + c = 0 and below we calculate the
				// parameters a,b and c for each test.
				// Check against points:
				a = velocitySquaredLength;
				// P1
				b = 2.0 * dot(velocity, base - p1);
				c = squaredLength(p1 - base) - 1.0;
				if (getLowestRoot(a, b, c, t, &newT)) {
					t = newT;
					foundCollison = true;
					collisionPoint = p1;
				}
				// P2
				b = 2.0 * dot(velocity, base - p2);
				c = squaredLength(p2 - base) - 1.0;
				if (getLowestRoot(a, b, c, t, &newT)) {
					t = newT;
					foundCollison = true;
					collisionPoint = p2;
				}
				// P3
				b = 2.0 * dot(velocity, base - p3);
				c = squaredLength(p3 - base) - 1.0;
				if (getLowestRoot(a, b, c, t, &newT)) {
					t = newT;
					foundCollison = true;
					collisionPoint = p3;
				}
				// Check against edges:
				// p1 -> p2:
				D3DVECTOR edge = p2 - p1;
				D3DVECTOR baseToVertex = p1 - base;
				float edgeSquaredLength = squaredLength(edge);
				float edgeDotVelocity = dot(edge,velocity);
				float edgeDotBaseToVertex = dot(edge, baseToVertex);
				// Calculate parameters for equation
				a = edgeSquaredLength * -velocitySquaredLength
						+ edgeDotVelocity * edgeDotVelocity;
				b = edgeSquaredLength * (2 * dot(velocity,baseToVertex))
						- 2.0 * edgeDotVelocity * edgeDotBaseToVertex;
				c = edgeSquaredLength * (1 - squaredLength(baseToVertex))
						+ edgeDotBaseToVertex * edgeDotBaseToVertex;
				// Does the swept sphere collide against infinite edge?
				if (getLowestRoot(a, b, c, t, &newT)) {
					// Check if intersection is within line segment:
					float f =
							(edgeDotVelocity * newT - edgeDotBaseToVertex)
									/ edgeSquaredLength;
					if (f >= 0.0 && f <= 1.0) {
						// intersection took place within segment.
						t = newT;
						foundCollison = true;
						collisionPoint = p1 + f * edge;
					}
				}
				// p2 -> p3:
				edge = p3 - p2;
				baseToVertex = p2 - base;
				edgeSquaredLength = squaredLength(edge);
				edgeDotVelocity = dot(edge,velocity);
				edgeDotBaseToVertex = dot(edge,baseToVertex);
				a = edgeSquaredLength * -velocitySquaredLength
						+ edgeDotVelocity * edgeDotVelocity;
				b = edgeSquaredLength * (2 * dot(velocity,baseToVertex))
						- 2.0 * edgeDotVelocity * edgeDotBaseToVertex;
				c = edgeSquaredLength * (1 - squaredLength(baseToVertex))
						+ edgeDotBaseToVertex * edgeDotBaseToVertex;
				if (getLowestRoot(a, b, c, t, &newT)) {
					float f =
							(edgeDotVelocity * newT - edgeDotBaseToVertex)
									/ edgeSquaredLength;
					if (f >= 0.0 && f <= 1.0) {
						t = newT;
						foundCollison = true;
						collisionPoint = p2 + f * edge;
					}
				}
				// p3 -> p1:
				edge = p1 - p3;
				baseToVertex = p3 - base;
				edgeSquaredLength = squaredLength(edge);
				edgeDotVelocity = dot(edge, velocity);
				edgeDotBaseToVertex = dot(edge, baseToVertex);
				a = edgeSquaredLength * -velocitySquaredLength
						+ edgeDotVelocity * edgeDotVelocity;
				b = edgeSquaredLength * (2 * dot(velocity, baseToVertex))
						- 2.0 * edgeDotVelocity * edgeDotBaseToVertex;
				c = edgeSquaredLength * (1 - squaredLength(baseToVertex))
						+ edgeDotBaseToVertex * edgeDotBaseToVertex;
				if (getLowestRoot(a, b, c, t, &newT)) {
					float f =
							(edgeDotVelocity * newT - edgeDotBaseToVertex)
									/ edgeSquaredLength;
					if (f >= 0.0 && f <= 1.0) {
						t = newT;
						foundCollison = true;
						collisionPoint = p3 + f * edge;
					}
				}
			}
			// Set result:
			if (foundCollison == true) {
				// distance to collision: ’t’ is time of collision
				float distToCollision = t * length(colPackage->velocity);
				// Does this triangle qualify for the closest hit?
				// it does if it’s the first hit or the closest
				if (colPackage->foundCollision == false || distToCollision
						< colPackage->nearestDistance) {
					// Collision information nessesary for sliding
					colPackage->nearestDistance = distToCollision;
					colPackage->intersectionPoint = collisionPoint;
					colPackage->foundCollision = true;
				}
			}
		} // if not backface
	} // for all faces
}

typedef unsigned int uint32;
#define in(a) ((uint32&) a)
bool checkPointInTriangle(const D3DVECTOR& point, const D3DVECTOR& pa,
		const D3DVECTOR& pb, const D3DVECTOR& pc) {
	D3DVECTOR e10 = pb - pa;
	D3DVECTOR e20 = pc - pa;
	float a = dot(e10, e10);
	float b = dot(e10, e20);
	float c = dot(e20, e20);
	float ac_bb = (a * c) - (b * b);
	D3DVECTOR vp = d3dvector(point.x - pa.x, point.y - pa.y, point.z - pa.z);
	float d = dot(vp, e10);
	float e = dot(vp, e20);
	float x = (d * c) - (e * b);
	float y = (e * a) - (d * b);
	float z = x + y - ac_bb;
	return ((in(z) & ~(in(x) | in(y))) & 0x80000000);
}

bool getLowestRoot(float a, float b, float c, float maxR, float* root) {
	// Check if a solution exists
	float determinant = b * b - 4.0f * a * c;
	// If determinant is negative it means no solutions.
	if (determinant < 0.0f)
		return false;
	// calculate the two roots: (if determinant == 0 then
	// x1==x2 but let’s disregard that slight optimization)
	float sqrtD = sqrt(determinant);
	float r1 = (-b - sqrtD) / (2 * a);
	float r2 = (-b + sqrtD) / (2 * a);
	// Sort so x1 <= x2
	if (r1 > r2) {
		float temp = r2;
		r2 = r1;
		r1 = temp;
	}
	// Get lowest root:
	if (r1 > 0 && r1 < maxR) {
		*root = r1;
		return true;
	}
	// It is possible that we want x2 - this can happen
	// if x1 < 0
	if (r2 > 0 && r2 < maxR) {
		*root = r2;
		return true;
	}
	// No (valid) solutions
	return false;
}

PLANE::PLANE(const D3DVECTOR& origin, const D3DVECTOR& normal) {
	this->normal = normal;
	this->origin = origin;
	equation[0] = normal.x;
	equation[1] = normal.y;
	equation[2] = normal.z;
	equation[3] = -(normal.x * origin.x + normal.y * origin.y + normal.z
			* origin.z);
}
// Construct from triangle:
PLANE::PLANE(const D3DVECTOR& p1, const D3DVECTOR& p2, const D3DVECTOR& p3) {
	normal = cross(p2 - p1, p3 - p1);
	normalize(normal);
	origin = p1;
	equation[0] = normal.x;
	equation[1] = normal.y;
	equation[2] = normal.z;
	equation[3] = -(normal.x * origin.x + normal.y * origin.y + normal.z
			* origin.z);
}
bool PLANE::isFrontFacingTo(const D3DVECTOR& direction) const {
	double d = dot(normal, direction);
	return (d <= 0);
}
double PLANE::signedDistanceTo(const D3DVECTOR& point) const {
	return (dot(point, normal)) + equation[3];
}



vectormath.h

#ifndef VECTORMATH_H
#define VECTORMATH_H
#include <d3dvector.h>
#include <math.h>

#define PLANE_BACKSIDE 0x000001
#define PLANE_FRONT    0x000010
#define ON_PLANE       0x000100

// basic vector operations (inlined)
inline float dot(D3DVECTOR& v1, D3DVECTOR& v2) {
	return (v1.x * v2.x + v1.y * v2.y + v1.z * v2.z);
}

inline void normalizeVector(D3DVECTOR& v) {
	float len = sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
	v.x /= len;
	v.y /= len;
	v.z /= len;
}

inline float lengthOfVector(D3DVECTOR v) {
	return sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
}

inline void setLength(D3DVECTOR& v, float l) {
	float len = sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
	v.x *= l / len;
	v.y *= l / len;
	v.z *= l / len;
}

inline BOOL isZeroVector(D3DVECTOR& v) {
	if ((v.x == 0.0f) && (v.y == 0.0f) && (v.z == 0.0f))
		return TRUE;

	return FALSE;
}

inline D3DVECTOR cross(D3DVECTOR v1, D3DVECTOR v2) {
	D3DVECTOR result;

	result.x = (v1.y * v2.z) - (v2.y * v1.z);
	result.y = (v1.z * v2.x) - (v2.z * v1.x);
	result.z = (v1.x * v2.y) - (v2.x * v1.y);

	return (result);
}

// ray intersections. All return -1.0 if no intersection, otherwise the distance along the 
// ray where the (first) intersection takes place
float intersectRayPlane(D3DVECTOR rOrigin, D3DVECTOR rVector,
		D3DVECTOR pOrigin, D3DVECTOR pNormal);
float intersectRaySphere(D3DVECTOR rO, D3DVECTOR rV, D3DVECTOR sO, float sR);

// Distance to line of triangle
D3DVECTOR closestPointOnLine(D3DVECTOR& a, D3DVECTOR& b, D3DVECTOR& p);
D3DVECTOR closestPointOnTriangle(D3DVECTOR a, D3DVECTOR b, D3DVECTOR c,
		D3DVECTOR p);

// point inclusion
BOOL CheckPointInTriangle(D3DVECTOR point, D3DVECTOR a, D3DVECTOR b,
		D3DVECTOR c);
BOOL CheckPointInSphere(D3DVECTOR point, D3DVECTOR sO, float sR);

// Normal generation
D3DVECTOR tangentPlaneNormalOfEllipsoid(D3DVECTOR point, D3DVECTOR eO,
		D3DVECTOR eR);

// Point classification
DWORD classifyPoint(D3DVECTOR point, D3DVECTOR pO, D3DVECTOR pN);

// Sphere Triangle test
BOOL TestSphereTriangle(D3DVECTOR sc, float sr, D3DVECTOR a, D3DVECTOR b,
		D3DVECTOR c);

#endif // VECTORMATH_H


vectormath.cpp

#define PI 3.14159f
#define TWOPI 6.28318f

// ----------------------------------------------------------------------
// Name  : intersectRayPlane()
// Input : rOrigin - origin of ray in world space
//         rVector - vector describing direction of ray in world space
//         pOrigin - Origin of plane 
//         pNormal - Normal to plane
// Notes : Normalized directional vectors expected
// Return: distance to plane in world units, -1 if no intersection.
// -----------------------------------------------------------------------  
float intersectRayPlane(D3DVECTOR rOrigin, D3DVECTOR rVector,
		D3DVECTOR pOrigin, D3DVECTOR pNormal) {

	float d = -(dot(pNormal, pOrigin));

	float numer = dot(pNormal, rOrigin) + d;
	float denom = dot(pNormal, rVector);

	if (denom == 0) // normal is orthogonal to vector, cant intersect
		return (-1.0f);

	return -(numer / denom);
}

// ----------------------------------------------------------------------
// Name  : intersectRaySphere()
// Input : rO - origin of ray in world space
//         rV - vector describing direction of ray in world space
//         sO - Origin of sphere 
//         sR - radius of sphere
// Notes : Normalized directional vectors expected
// Return: distance to sphere in world units, -1 if no intersection.
// -----------------------------------------------------------------------  

float intersectRaySphere(D3DVECTOR rO, D3DVECTOR rV, D3DVECTOR sO, float sR) {

	D3DVECTOR Q = sO - rO;

	float c = lengthOfVector(Q);
	float v = dot(Q, rV);
	float d = sR * sR - (c * c - v * v);

	// If there was no intersection, return -1
	if (d < 0.0)
		return (-1.0f);

	// Return the distance to the [first] intersecting point
	return (v - sqrt(d));
}

// ----------------------------------------------------------------------
// Name  : CheckPointInTriangle()
// Input : point - point we wish to check for inclusion
//         a - first vertex in triangle
//         b - second vertex in triangle 
//         c - third vertex in triangle
// Notes : Triangle should be defined in clockwise order a,b,c
// Return: TRUE if point is in triangle, FALSE if not.
// -----------------------------------------------------------------------  

BOOL CheckPointInTriangle(D3DVECTOR point, D3DVECTOR a, D3DVECTOR b,
		D3DVECTOR c) {
	// using barycentric method - this is supposedly the fastest method there is for this.
	// from http://www.blackpawn.com/texts/pointinpoly/default.html
	// Compute vectors
	D3DVECTOR v0 = c - a;
	D3DVECTOR v1 = b - a;
	D3DVECTOR v2 = point - a;

	// Compute dot products
	float dot00 = dot(v0, v0);
	float dot01 = dot(v0, v1);
	float dot02 = dot(v0, v2);
	float dot11 = dot(v1, v1);
	float dot12 = dot(v1, v2);

	// Compute barycentric coordinates
	float invDenom = 1 / (dot00 * dot11 - dot01 * dot01);
	float u = (dot11 * dot02 - dot01 * dot12) * invDenom;
	float v = (dot00 * dot12 - dot01 * dot02) * invDenom;

	// Check if point is in triangle
	return (u > 0) && (v > 0) && (u + v < 1);
}

// ----------------------------------------------------------------------
// Name  : closestPointOnLine()
// Input : a - first end of line segment
//         b - second end of line segment
//         p - point we wish to find closest point on line from 
// Notes : Helper function for closestPointOnTriangle()
// Return: closest point on line segment
// -----------------------------------------------------------------------  

D3DVECTOR closestPointOnLine(D3DVECTOR& a, D3DVECTOR& b, D3DVECTOR& p) {

	// Determine t (the length of the vector from ‘a’ to ‘p’)
	D3DVECTOR c = p - a;
	D3DVECTOR V = b - a;

	float d = lengthOfVector(V);

	normalizeVector(V);
	float t = dot(V, c);

	// Check to see if ‘t’ is beyond the extents of the line segment
	if (t < 0.0f)
		return (a);
	if (t > d)
		return (b);

	// Return the point between ‘a’ and ‘b’
	//set length of V to t. V is normalized so this is easy
	V.x = V.x * t;
	V.y = V.y * t;
	V.z = V.z * t;

	return (a + V);
}

// ----------------------------------------------------------------------
// Name  : closestPointOnTriangle()
// Input : a - first vertex in triangle
//         b - second vertex in triangle 
//         c - third vertex in triangle
//         p - point we wish to find closest point on triangle from 
// Notes : 
// Return: closest point on line triangle edge
// -----------------------------------------------------------------------  

D3DVECTOR closestPointOnTriangle(D3DVECTOR a, D3DVECTOR b, D3DVECTOR c,
		D3DVECTOR p) {

	D3DVECTOR Rab = closestPointOnLine(a, b, p);
	D3DVECTOR Rbc = closestPointOnLine(b, c, p);
	D3DVECTOR Rca = closestPointOnLine(c, a, p);

	float dAB = lengthOfVector(p - Rab);
	float dBC = lengthOfVector(p - Rbc);
	float dCA = lengthOfVector(p - Rca);

	float min = dAB;
	D3DVECTOR result = Rab;

	if (dBC < min) {
		min = dBC;
		result = Rbc;
	}

	if (dCA < min)
		result = Rca;

	return (result);
}

// ----------------------------------------------------------------------
// Name  : CheckPointInTriangle()
// Input : point - point we wish to check for inclusion
//         sO - Origin of sphere
//         sR - radius of sphere 
// Notes : 
// Return: TRUE if point is in sphere, FALSE if not.
// -----------------------------------------------------------------------  

BOOL CheckPointInSphere(D3DVECTOR point, D3DVECTOR sO, float sR) {

	float d = lengthOfVector(point - sO);

	if (d <= sR)
		return TRUE;
	return FALSE;
}

// ----------------------------------------------------------------------
// Name  : tangentPlaneNormalOfEllipsoid()
// Input : point - point we wish to compute normal at 
//         eO - Origin of ellipsoid
//         eR - radius vector of ellipsoid 
// Notes : 
// Return: a unit normal vector to the tangent plane of the ellipsoid in the point.
// -----------------------------------------------------------------------  
D3DVECTOR tangentPlaneNormalOfEllipsoid(D3DVECTOR point, D3DVECTOR eO,
		D3DVECTOR eR) {

	D3DVECTOR p = point - eO;

	float a2 = eR.x * eR.x;
	float b2 = eR.y * eR.y;
	float c2 = eR.z * eR.z;

	D3DVECTOR res;
	res.x = p.x / a2;
	res.y = p.y / b2;
	res.z = p.z / c2;

	normalizeVector(res);
	return (res);
}

// ----------------------------------------------------------------------
// Name  : classifyPoint()
// Input : point - point we wish to classify 
//         pO - Origin of plane
//         pN - Normal to plane 
// Notes : 
// Return: One of 3 classification codes
// -----------------------------------------------------------------------  

DWORD classifyPoint(D3DVECTOR point, D3DVECTOR pO, D3DVECTOR pN) {

	D3DVECTOR dir = pO - point;
	float d = dot(dir, pN);

	if (d < -0.001f)
		return PLANE_FRONT;
	else if (d > 0.001f)
		return PLANE_BACKSIDE;

	return ON_PLANE;
}

// -------------------------- from real time collision detection --------------------
// Gets the closest point on a triangle nearest a given point.
D3DVECTOR ClosestPtPointTriangle(D3DVECTOR p, D3DVECTOR a, D3DVECTOR b, D3DVECTOR c, int* intersectionType) {
	// Check if P in vertex region outside A
	D3DVECTOR ab = b - a;
	D3DVECTOR ac = c - a;
	D3DVECTOR ap = p - a;
	float d1 = dot(ab, ap);
	float d2 = dot(ac, ap);
	if (d1 <= 0.0f && d2 <= 0.0f) {
		*intersectionType = 2;
		return a;
	}
	// Check if P in vertex region outside B
	D3DVECTOR bp = p - b;
	float d3 = dot(ab, bp);
	float d4 = dot(ac, bp);
	if (d3 >= 0.0f && d4 <= d3) {
		*intersectionType = 2;
		return b;
	}
	// Check if P in edge region of AB, if so return projection of P onto AB
	float vc = d1 * d4 - d3 * d2;
	if (vc <= 0.0f && d1 >= 0.0f && d3 <= 0.0f) {
		float v = d1 / (d1 - d3);
		*intersectionType = 1;
		return a + v * ab;
	}
	// Check if P in vertex region outside C
	D3DVECTOR cp = p - c;
	float d5 = dot(ab, cp);
	float d6 = dot(ac, cp);
	if (d6 >= 0.0f && d5 <= d6) {
		*intersectionType = 2;
		return c;
	}
	// Check if P in edge region of AC, if so return projection of P onto AC
	float vb = d5 * d2 - d1 * d6;
	if (vb <= 0.0f && d2 >= 0.0f && d6 <= 0.0f) {
		float w = d2 / (d2 - d6);
		*intersectionType = 1;
		return a + w * ac;
	}
	// Check if P in edge region of BC, if so return projection of P onto BC
	float va = d3 * d6 - d5 * d4;
	if (va <= 0.0f && (d4 - d3) >= 0.0f && (d5 - d6) >= 0.0f) {
		float w = (d4 - d3) / ((d4 - d3) + (d5 - d6));
		*intersectionType = 1;
		return b + w * (c - b);
	}
	// P inside face region.  Compute Q through its barycentric coordinates (u,v,w)
	float denom = 1.0f / (va + vb + vc);
	float v = vb * denom;
	float w = vc * denom;
	*intersectionType = 0;
	return a + ab * v + ac * w;
}

// From real time collision detection
// Tests a sphere against a triangle, returns true if intersection.
// Modify and pass in point P to get intersection point if desired.
BOOL TestSphereTriangle(D3DVECTOR sc, float sr, D3DVECTOR a, D3DVECTOR b,
		D3DVECTOR c) {
	//D3DVECTOR p = closestPointOnTriangle(a, b, c, sc);
	//__android_log_print(ANDROID_LOG_DEBUG, "VectorMath", "sc is %f %f %f", sc.x, sc.y, sc.z);
	//__android_log_print(ANDROID_LOG_DEBUG, "VectorMath", "a is %f %f %f", a.x, a.y, a.z);
	//__android_log_print(ANDROID_LOG_DEBUG, "VectorMath", "b is %f %f %f", b.x, b.y, b.z);
	//__android_log_print(ANDROID_LOG_DEBUG, "VectorMath", "c is %f %f %f", c.x, c.y, c.z);
	int colType;
	D3DVECTOR p = ClosestPtPointTriangle(sc, a, b, c, &colType);
	//__android_log_print(ANDROID_LOG_DEBUG, "VectorMath", "p is %f %f %f", p.x, p.y, p.z);
	D3DVECTOR v = p - sc;
	//__android_log_print(ANDROID_LOG_DEBUG, "VectorMath", "v is %f %f %f", v.x, v.y, v.z);
	//float dv = dot(v, v);
	//float sr2 = sr * sr;
	//__android_log_print(ANDROID_LOG_DEBUG, "VectorMath", "dot vv is %f, sr2 is %f", dv, sr2);
	return dot(v, v) <= sr * sr;
}



