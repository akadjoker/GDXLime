package com.gdx.math;

/**
 * ...
 * @author Luis Santos AKA DJOKER
 */
	

            private bool GetLowestRoot(float a, float b, float c, float maxR, ref float root)
            {
                // Check if a solution exists
                float determinant = b * b - 4.0f * a * c;
     
                // If determinant is negative it means no solutions.
                if (determinant < 0.0f) return false;
     
                // calculate the two roots: (if determinant == 0 then
                // x1==x2 but let�s disregard that slight optimization)
                float sqrtD = (float)Math.Sqrt(determinant);
                float r1 = (-b - sqrtD) / (2 * a);
                float r2 = (-b + sqrtD) / (2 * a);
     
                // Sort so x1 <= x2
                if (r1 > r2)
                {
                    float temp = r2;
                    r2 = r1;
                    r1 = temp;
                }
               
                // Get lowest root:
                if (r1 > 0 && r1 < maxR)
                {
                    root = r1;
                    return true;
                }
               
                // It is possible that we want x2 - this can happen
                // if x1 < 0
                if (r2 > 0 && r2 < maxR)
                {
                    root = r2;
                    return true;
                }
     
                // No (valid) solutions
                return false;
            }
     
     
            /// <summary>
            /// Check point P to see if it is within the triangle A B C.
            /// </summary>
            private bool CheckPointInTriangle(Vector3 P, Vector3 A, Vector3 B, Vector3 C)
            {
                //Distance Vectors        
                Vector3 p1 = C - A;
                Vector3 p2 = B - A;
                Vector3 p3 = P - A;
     
                //Get all the Vector Dots
                float dot11 = Vector3.Dot(p1, p1);
                float dot12 = Vector3.Dot(p1, p2);
                float dot13 = Vector3.Dot(p1, p3);
                float dot22 = Vector3.Dot(p2, p2);
                float dot23 = Vector3.Dot(p2, p3);
     
                //Barycentric Co-ordinates
                float invDenom = 1 / (dot11 * dot22 - dot12 * dot12);
                float u = (dot22 * dot13 - dot12 * dot23) * invDenom;
                float v = (dot11 * dot23 - dot12 * dot13) * invDenom;
     
                // Is 'P' in the Triangle?
                return (u > 0) && (v > 0) && (u + v < 1);
            }
     
     
            /// <summary>
            /// Check a triangle for collision. Assumes p1,p2 and p3 are given in ellipsoid space.
            /// </summary>
            private void CheckTriangle(CollisionPacket colPackage, Vector3 p1, Vector3 p2, Vector3 p3)
            {
                // Make the plane containing this triangle.
                tPlane trianglePlane = new tPlane(p1, p2, p3);
     
                // Is triangle front-facing to the velocity vector?
                // We only check front-facing triangles
                // (your choice of course)
     
                //if (trianglePlane.isFrontFacingTo(colPackage.normalizedVelocity))
                if(true)
                {
                    // Get interval of plane intersection:
                    double t0, t1;
                    bool embeddedInPlane = false;
     
                    // Calculate the signed distance from sphere
                    // position to triangle plane
                    double signedDistToTrianglePlane = trianglePlane.signedDistanceTo(colPackage.basePoint);
     
                    // cache this as we�re going to use it a few times below:
                    float normalDotVelocity = Vector3.Dot(trianglePlane.normal, colPackage.velocity);
     
                    // if sphere is travelling parrallel to the plane:
                    if (normalDotVelocity == 0.0f){
                        if (Math.Abs(signedDistToTrianglePlane) >= 1.0f){
                            // Sphere is not embedded in plane.
                            // No collision possible:
                            return;
                        }else{
                            // sphere is embedded in plane.
                            // It intersects in the whole range [0..1]
                            embeddedInPlane = true;
                            t0 = 0.0;
                            t1 = 1.0;
                        }
                    }else{
                        // N dot D is not 0. Calculate intersection interval:
                        t0 = (-1.0 - signedDistToTrianglePlane) / normalDotVelocity;
                        t1 = (1.0 - signedDistToTrianglePlane) / normalDotVelocity;
                       
                        // Swap so t0 < t1
                        if (t0 > t1){
                            double temp = t1;
                            t1 = t0;
                            t0 = temp;
                        }
                       
                        // Check that at least one result is within range:
                        if (t0 > 1.0f || t1 < 0.0f){
                            // Both t values are outside values [0,1]
                            // No collision possible:
                            return;
                        }
     
                        // Clamp to [0,1]
                        if (t0 < 0.0) t0 = 0.0;
                        if (t1 < 0.0) t1 = 0.0;
                        if (t0 > 1.0) t0 = 1.0;
                        if (t1 > 1.0) t1 = 1.0;
                    }
     
                    // OK, at this point we have two time values t0 and t1
                    // between which the swept sphere intersects with the
                    // triangle plane. If any collision is to occur it must
                    // happen within this interval.
                    Vector3 collisionPoint = new Vector3();
                    bool foundCollison = false;
                    float t = 1.0f;
     
                    // First we check for the easy case - collision inside
                    // the triangle. If this happens it must be at time t0
                    // as this is when the sphere rests on the front side
                    // of the triangle plane. Note, this can only happen if
                    // the sphere is not embedded in the triangle plane.
                    if (!embeddedInPlane)
                    {
                        Vector3 planeIntersectionPoint;
     
                        planeIntersectionPoint =
                            (trianglePlane.isFrontFacingTo(colPackage.normalizedVelocity)) ?
                                (colPackage.basePoint - trianglePlane.normal) :
                                (colPackage.basePoint + trianglePlane.normal);
                        planeIntersectionPoint += Vector3.Multiply(colPackage.velocity, (float)t0);
     
     
     
                        if (CheckPointInTriangle(planeIntersectionPoint, p1, p2, p3))
                        {
                            foundCollison = true;
                            t = (float)t0;
                            //myDebug.write(trianglePlane.isFrontFacingTo(colPackage.normalizedVelocity).ToString() + " - " + colPackage.normalizedVelocity.ToString());
                            collisionPoint = planeIntersectionPoint;
                            //myDebug.writeVector("Found collision in a plane: ", planeIntersectionPoint * colPackage.eRadius);
                            //myDebug.writeVector("Base Point: ", colPackage.basePoint * colPackage.eRadius);
                            colPackage.collisionTri.v1 = p1;
                            colPackage.collisionTri.v2 = p2;
                            colPackage.collisionTri.v3 = p3;
                        }
                    }
     
                    // if we haven�t found a collision already we�ll have to
                    // sweep sphere against points and edges of the triangle.
                    // Note: A collision inside the triangle (the check above)
                    // will always happen before a vertex or edge collision!
                    // This is why we can skip the swept test if the above
                    // gives a collision!
                    if (foundCollison == false)
                    {
                        // some commonly used terms:
                        Vector3 velocity = colPackage.velocity;
                        Vector3 basePoint = colPackage.basePoint;
                        float velocitySquaredLength = velocity.LengthSquared();
                        float a, b, c; // Params for equation
                        float newT = 0.0f;
     
                        // For each vertex or edge a quadratic equation have to
                        // be solved. We parameterize this equation as
                        // a*t^2 + b*t + c = 0 and below we calculate the
                        // parameters a,b and c for each test.
                        // Check against points:
                        a = velocitySquaredLength;
     
                        // P1
                        b = 2 * Vector3.Dot(velocity, basePoint - p1);
                        c = (p1 - basePoint).LengthSquared() - 1.0f;
                        if (GetLowestRoot(a, b, c, t, ref newT))
                        {
                            t = newT;
                            foundCollison = true;
                            collisionPoint = p1;
                            myDebug.writeVector("Found collision in a p1 corner:", p1 * colPackage.eRadius);
                        }
     
                        // P2
                        b = 2 * Vector3.Dot(velocity, basePoint - p2);
                        c = (p2 - basePoint).LengthSquared() - 1.0f;
                        if (GetLowestRoot(a, b, c, t, ref newT))
                        {
                            t = newT;
                            foundCollison = true;
                            collisionPoint = p2;
                            myDebug.writeVector("Found collision in a p2 corner: ", p2 * colPackage.eRadius);
                        }
     
                        // P3
                        b = 2 * Vector3.Dot(velocity, basePoint - p3);
                        c = (p3 - basePoint).LengthSquared() - 1.0f;
                        if (GetLowestRoot(a, b, c, t, ref newT))
                        {
                            t = newT;
                            foundCollison = true;
                            collisionPoint = p3;
                            myDebug.writeVector("Found collision in a p3 corner: ", p3 * colPackage.eRadius);
                        }
     
                        //------------------------------
                        // Check agains edges:
                        //------------------------------
     
                        // p1 -> p2:
                        //------------------------------
                        Vector3 edge = p2 - p1;
                        Vector3 baseToVertex = p1 - basePoint;
                        float edgeSquaredLength = edge.LengthSquared();
                        float edgeDotVelocity = Vector3.Dot(edge, velocity);
                        float edgeDotBaseToVertex = Vector3.Dot(edge, baseToVertex);
     
                        // Calculate parameters for equation
                        a = (edgeSquaredLength * -velocitySquaredLength) + (edgeDotVelocity * edgeDotVelocity);
                        b = edgeSquaredLength * (2 * Vector3.Dot(velocity, baseToVertex)) - (2 * edgeDotVelocity * edgeDotBaseToVertex);
                        c = edgeSquaredLength * (1 - baseToVertex.LengthSquared()) + (edgeDotBaseToVertex * edgeDotBaseToVertex);
     
                        // Does the swept sphere collide against infinite edge?
                        if (GetLowestRoot(a, b, c, t, ref newT))
                        {
                            // Check if intersection is within line segment:
                            float f = (edgeDotVelocity * newT - edgeDotBaseToVertex) / edgeSquaredLength;
                            if (f >= 0.0 && f <= 1.0)
                            {
                                // intersection took place within segment.
                                t = newT;
                                foundCollison = true;
                                collisionPoint = p1 + (f * edge);
                                myDebug.writeVector("Found collision on the p1 - p2 edge:", collisionPoint * colPackage.eRadius);
                            }
                        }
     
                        // p2 -> p3:
                        //------------------------------
                        edge = p3 - p2;
                        baseToVertex = p2 - basePoint;
                        edgeSquaredLength = edge.LengthSquared();
                        edgeDotVelocity = Vector3.Dot(edge, velocity);
                        edgeDotBaseToVertex = Vector3.Dot(edge, baseToVertex);
     
                        a = (edgeSquaredLength * -velocitySquaredLength) + (edgeDotVelocity * edgeDotVelocity);
                        b = edgeSquaredLength * (2 * Vector3.Dot(velocity, baseToVertex)) - (2.0f * edgeDotVelocity * edgeDotBaseToVertex);
                        c = edgeSquaredLength * (1 - baseToVertex.LengthSquared()) + (edgeDotBaseToVertex * edgeDotBaseToVertex);
     
                        if (GetLowestRoot(a, b, c, t, ref newT))
                        {
                            float f = (edgeDotVelocity * newT - edgeDotBaseToVertex) / edgeSquaredLength;
                            if (f >= 0.0 && f <= 1.0)
                            {
                                t = newT;
                                foundCollison = true;
                                collisionPoint = p2 + (f * edge);
                                myDebug.writeVector("Found collision on the p2 - p3 edge:", collisionPoint * colPackage.eRadius);
                            }
                        }
     
                        // p3 -> p1:
                        //------------------------------
                        edge = p1 - p3;
                        baseToVertex = p3 - basePoint;
                        edgeSquaredLength = edge.LengthSquared();
                        edgeDotVelocity = Vector3.Dot(edge, velocity);
                        edgeDotBaseToVertex = Vector3.Dot(edge, baseToVertex);
     
                        a = edgeSquaredLength * -velocitySquaredLength + (edgeDotVelocity * edgeDotVelocity);
                        b = edgeSquaredLength * (2 * Vector3.Dot(velocity, baseToVertex)) - (2.0f * edgeDotVelocity * edgeDotBaseToVertex);
                        c = edgeSquaredLength * (1 - baseToVertex.LengthSquared()) + (edgeDotBaseToVertex * edgeDotBaseToVertex);
     
                        if (GetLowestRoot(a, b, c, t, ref newT))
                        {
                            float f = (edgeDotVelocity * newT - edgeDotBaseToVertex) / edgeSquaredLength;
                            if (f >= 0.0 && f <= 1.0)
                            {
                                t = newT;
                                foundCollison = true;
                                collisionPoint = p3 + (f * edge);
                                myDebug.writeVector("Found collision on the p3 - p1 edge:", collisionPoint * colPackage.eRadius);
                            }
                        }
                    }//Emd If Collision Found
     
                    //------------------------------
                    // Set result:
                    //------------------------------
                    if (foundCollison == true)
                    {
                        // distance to collision: �t� is time of collision
                        float distToCollision = t * colPackage.velocity.Length();
                       
                        // Does this triangle qualify for the closest hit?
                        // it does if it�s the first hit or the closest
                        if (colPackage.foundCollision == false || distToCollision < colPackage.nearestDistance){
     
                            // Collision information nessesary for sliding
                            colPackage.nearestDistance = distToCollision;
                            colPackage.intersectionPoint = collisionPoint;
                            colPackage.foundCollision = true;
                            colPackage.t = t;
                        }
                    }
                }//End if not backface
            }
     
     
            /// <summary>
            ///
            /// </summary>
            private Vector3 CollideWithWorld(Vector3 pos, Vector3 vel)
            {
     
                float unitsPerMeter = 1000.0f; //Set this to match application scale.
                // All hard-coded distances in this function is
                // scaled to fit the setting above..
                float unitScale = unitsPerMeter / 100.0f;
                float veryCloseDistance = 0.005f * unitScale;
     
                // do we need to worry?
                if (collisionRecursionDepth > 5)
                    return pos;
     
                // Ok, we need to worry:
                collisionPackage.velocity = vel;
                collisionPackage.normalizedVelocity = vel;
                collisionPackage.normalizedVelocity.Normalize();
                collisionPackage.basePoint = pos;
                collisionPackage.foundCollision = false;
     
                //Check all triangles for collision.
                foreach (TriangleVertexIndice t in idcs)
                {
                    CheckTriangle(collisionPackage,
                                            vtcs[t.i0] / collisionPackage.eRadius,
                                            vtcs[t.i1] / collisionPackage.eRadius,
                                            vtcs[t.i2] / collisionPackage.eRadius);
                    if (collisionPackage.foundCollision)
                    {
                        //Console.WriteLine("Collision Found! "+ collisionPackage.intersectionPoint.ToString());
                        collisionPoint.tri = collisionPackage.collisionTri;
                        collisionPoint.tri.v1 *= collisionPackage.eRadius;
                        collisionPoint.tri.v2 *= collisionPackage.eRadius;
                        collisionPoint.tri.v3 *= collisionPackage.eRadius;
                        collisionPoint.colpack = collisionPackage;
                        //break;
     
                    }
                }
     
                // If no collision we just move along the velocity
                if (collisionPackage.foundCollision == false)
                {
                    return pos + vel;
                }
     
                // *** Collision occured ***
                // The original destination point
                Vector3 destinationPoint = pos + vel;
                Vector3 newBasePoint = pos;
     
                // only update if we are not already very close
                // and if so we only move very close to intersection..not
                // to the exact spot.
     
                if (collisionPackage.nearestDistance >= veryCloseDistance)
                {
                    Vector3 V = vel;
                    V.Normalize();
                    V = Vector3.Multiply(V, (float)(collisionPackage.nearestDistance - veryCloseDistance));
                    //V.SetLength = (collisionPackage.nearestDistance - veryCloseDistance);
     
                    newBasePoint = collisionPackage.basePoint + V;
     
                    // Adjust polygon intersection point (so sliding
                    // plane will be unaffected by the fact that we
                    // move slightly less than collision tells us)
                    V.Normalize();
                    collisionPackage.intersectionPoint -= (veryCloseDistance * V);
                }
     
                // Determine the sliding plane
                Vector3 slidePlaneOrigin = collisionPackage.intersectionPoint;
                Vector3 slidePlaneNormal = newBasePoint - collisionPackage.intersectionPoint;
                slidePlaneNormal.Normalize();
                tPlane slidingPlane = new tPlane(slidePlaneOrigin, slidePlaneNormal);
     
                // Again, sorry about formatting.. but look carefully ;)
                Vector3 newDestinationPoint = destinationPoint - Vector3.Multiply(slidePlaneNormal, (float)slidingPlane.signedDistanceTo(destinationPoint));
     
                // Generate the slide vector, which will become our new velocity vector for the next iteration
                Vector3 newVelocityVector = newDestinationPoint - collisionPackage.intersectionPoint;
     
                // Recurse: Don't recurse if the new velocity is very small
                if (newVelocityVector.Length() < veryCloseDistance)
                {
                    return newBasePoint;
                }
     
                collisionRecursionDepth++;
                return CollideWithWorld(newBasePoint, newVelocityVector);
            }
     
     
            /// <summary>
            /// Conversion to eSpace for collideWithWorld.
            /// </summary>
            public Vector3 CollideAndSlide(Vector3 pos, Vector3 vel, Vector3 gravity)
            {
     
     
                // Do collision detection:
                collisionPackage.R3Position = pos;
                collisionPackage.R3Position.Y += collisionPackage.eRadius.Y;
                collisionPackage.R3Velocity = vel;
     
                // calculate position and velocity in eSpace
                Vector3 eSpacePosition = collisionPackage.R3Position / collisionPackage.eRadius;
                Vector3 eSpaceVelocity = collisionPackage.R3Velocity / collisionPackage.eRadius;
     
                // Iterate until we have our final position.
                collisionRecursionDepth = 0;
                Vector3 finalPosition = CollideWithWorld(eSpacePosition, eSpaceVelocity);
               
                // [gravity]
                collisionPackage.R3Position = finalPosition * collisionPackage.eRadius;
                collisionPackage.R3Velocity = gravity;
                eSpaceVelocity = gravity / collisionPackage.eRadius;
                collisionRecursionDepth = 0;
                finalPosition = CollideWithWorld(finalPosition, eSpaceVelocity);
                // [/gravity]
     
               
                // Convert final result back to R3:
                finalPosition = finalPosition * collisionPackage.eRadius;
                finalPosition.Y -= collisionPackage.eRadius.Y;
     
                // Move the entity (application specific function)
                return finalPosition;
            }

