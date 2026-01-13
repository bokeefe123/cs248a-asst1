implementing "../primitive.slang";
import math;

public struct Triangle : IRayCastable
{
    public float3[3] vertices;
    public float3[3] normals;
    public float2[3] uvs;
    public float3[3] colors;
    public uint materialId;

    /* Returns the average color of the triangle. */
    public float3 averageColor()
    {
        return (this.colors[0] + this.colors[1] + this.colors[2]) / 3.0;
    }

    /**
     * Test ray-triangle intersection.
     * @param ray The ray to test against the triangle.
     * @return An Optional containing RayHitResult if the ray hits the triangle, otherwise an empty Optional.
     */
    public Optional<RayHitResult> hit(Ray ray)
    {
        // TODO: Student implementation starts here.
        float3 normalVector = cross(vertices[1] - vertices[0], vertices[2] - vertices[0]);
        float triangleArea = length(normalVector);
        // normalVector = normalize(normalVector);
        float offset = dot(normalVector, vertices[0]);
        float t = (offset - dot(normalVector, ray.origin)) / dot(normalVector, ray.direction);
        float3 p = ray.origin + t * ray.direction;

        float alpha = length(cross(p - vertices[1], p - vertices[2])) / (triangleArea);
        float beta = length(cross(p - vertices[2], p - vertices[0])) / (triangleArea);
        float gamma = length(cross(p - vertices[0], p - vertices[1])) / (triangleArea);
        if (alpha >= 0 && alpha <= 1 && beta >= 0 && beta <= 1 && gamma >= 0 && gamma <= 1 && abs(alpha + beta + gamma - 1.0) < 1e-6) {
            return Optional<RayHitResult>(RayHitResult(t, normalVector));
        } 

        return Optional<RayHitResult>();
        // TODO: Student implementation ends here.
    }
}
