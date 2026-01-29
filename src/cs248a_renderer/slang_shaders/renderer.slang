import math;
import texture;
import material;
import model;
import primitive;

public struct RendererUniform
{
    // Camera parameters.
    public Camera camera;
    // Ambient color, used when no ray hits a primitive
    public float4 ambientColor;
    // Ray samples per pixel
    public uint sqrtSpp;
    // Primitives.
    public StructuredBuffer<Triangle> triangleBuf;
    public uint triangleCount;
    public SharedTexture3DBuffer<float4> volumeTexBuf;
    public StructuredBuffer<Volume> volumeBuf;
    public uint volumeCount;
    public SDFBuffer sdfBuf;
    // Acceleration structure.
    public bool useBVH;
    public BVH<Triangle> bvh;

    public bool renderDepth;
    public bool renderNormal;
}

static uint MAX_STEPS = 100;
static float EPSILON = 1e-6;

/**
 * Sample the scene at the given uv coordinate.
 * @param uv The normalized uv coordinate from (0, 0) in the bottom-left to (1, 1) in the top-right.
 * @param uniforms The renderer uniform containing camera, sampling, and scene information.
 * @return The color of the ray sample at the given uv coordinate.
 */
public float4 sample(float2 uv, RendererUniform uniforms)
{
    // We generate a camera ray for the given uv coordinate.
    // You need to implement the `generateRay` function in `Camera` struct in `src/cs248a_renderer/slang_shaders/model/camera.slang`
    
    Ray ray = uniforms.camera.generateRay(uv);
    RayHitResult result;

    // TODO: Student implementation starts here.
    Optional<RayHitResult> closestHitResult;
    Optional<RayHitResult> hitResult;
    
    for (uint i = 0; i < uniforms.triangleCount; i++)
    {
        Triangle triangle = uniforms.triangleBuf[i];
        hitResult = triangle.hit(ray);
        if (!hitResult.hasValue) {}
        else if (!closestHitResult.hasValue) {
            closestHitResult = hitResult;
        }
        else if (hitResult.value.t < closestHitResult.value.t) {
            closestHitResult = hitResult;
        }  
    }
    
    for (uint i = 0; i < uniforms.volumeCount; i++)
    {
        Volume volume = uniforms.volumeBuf[i];
        hitResult = volume.hit(ray, uniforms.volumeTexBuf);
        if (!hitResult.hasValue) {}
        else if (!closestHitResult.hasValue) {
            closestHitResult = hitResult;
        }
        else if (hitResult.value.t < closestHitResult.value.t) {
            closestHitResult = hitResult;
        }  
    }

    float totalT = ray.tRange.x;
    for (uint i = 0; i < MAX_STEPS && totalT < ray.tRange.y; i++) {
        
        float3 samplePoint = ray.origin + totalT*ray.direction;
        Tuple<float, float3> sampleResult = uniforms.sdfBuf.sample(samplePoint);
        totalT += sampleResult._0;
        if (sampleResult._0 < EPSILON) {
            if (!closestHitResult.hasValue || totalT < closestHitResult.value.t) {
                closestHitResult = Optional<RayHitResult>(RayHitResult(totalT, sampleResult._1));
            }
            break;
        }
    }
    

    if (!closestHitResult.hasValue) {
        return float4(float3(0.0), 1.0);
    }
    result = closestHitResult.value;
    // TODO: Student implementation ends here.

    if (uniforms.renderDepth)
    {
        // Map depth to [0, 1] range for visualization
        return float4(float3(result.t), 1.0);
    }

    if (uniforms.renderNormal)
    {
        // Map normal from [-1, 1] to [0, 1] range for visualization
        return float4(result.normal * 0.5 + 0.5, 1.0);
    }

    // Once you have the intersection result, use the following code to shade (calculate color) for the ray.
    // The shading function needs the camera ray and the intersection result.
    SimpleMaterial simpleMaterial;
    float3 color = simpleMaterial.shade(ray, result);
    return float4(color, 1.0);
}

/**
 * The entry point of the renderer.
 * @param tid The 2D coordinate of the current thread. Ranges from (0, 0) to (canvasSize.x - 1, canvasSize.y - 1).
 * @param uniforms The renderer uniform containing camera, sampling, and scene information.
 * @return The color of the pixel at the given thread coordinate.
 */
public float4 render(uint2 tid, RendererUniform uniforms)
{
    // Basic version: no supersampling.
    // float2 uv = (float2(tid) + 0.5) / float2(uniforms.camera.canvasSize);
    // return sample(uv, uniforms);

    // TODO: Student implementation starts here.
    float4 returnedColor = float4(0);
    float2 uv = float2(0);
    float xOffset, yOffset;
    for (int i = 0; i < uniforms.sqrtSpp; i++) {

        for (int j = 0; j < uniforms.sqrtSpp; j++) {
            xOffset = 0.5 / float(uniforms.sqrtSpp) + float(i)*(1.0 / float(uniforms.sqrtSpp));
            yOffset = 0.5 / float(uniforms.sqrtSpp) + float(j)*(1.0 / float(uniforms.sqrtSpp));
            uv = float2(tid.x + xOffset, tid.y + yOffset);
            uv = uv / float2(uniforms.camera.canvasSize);
            returnedColor += sample(uv, uniforms) / float(uniforms.sqrtSpp * uniforms.sqrtSpp);
        }
    }
    return returnedColor;

    // TODO: Student implementation ends here.
}
