implementing "../texture.slang";

public struct SharedTexture3DBuffer<T>
    where T : IFloat
{
    public StructuredBuffer<T> buffer;

    T getBufferValue(SharedTexture3D tex, uint3 voxelCoord)
    {
        uint3 texSize = tex.size;
        uint offset = tex.offset;
        uint index = voxelCoord.z * texSize.y * texSize.x +
                     voxelCoord.y * texSize.x +
                     voxelCoord.x;
        return buffer[offset + index];
    }

    T lerp(T a, T b, float s) { 
        return a.mul(T(1.0 - s)).add(b.mul(T(s))); 
    }

    /**
     * Sample the texture at the given uvw coordinates using nearest neighbor interpolation.
     * @param tex The texture to sample.
     * @param uvw The uvw coordinates to sample the texture at.
     * @return The sampled value.
     */
    public T pointSample(SharedTexture3D tex, float3 uvw)
    {
        // TODO: Student implementation starts here.

        uvw = clamp(uvw, float3(0.0), float3(1.0));
        uint3 voxelCoord = uint3(uvw * tex.size);
        return getBufferValue(tex, voxelCoord);

        // TODO: Student implementation ends here.
    }

    /**
     * Sample the texture at the given uvw coordinates using trilinear interpolation.
     * @param tex The texture to sample.
     * @param uvw The uvw coordinates to sample the texture at.
     * @return The sampled value.
    **/
    public T trilinearSample(SharedTexture3D tex, float3 uvw)
    {
        // TODO: Student implementation starts here.
        
        // Return 0 if any coordinate is out of range
        if (any(uvw < float3(0.0)) || any(uvw > float3(1.0)))
            return T(0.0);
        float3 voxelCenter = uvw * float3(tex.size);
        uint3 baseVoxelCoord = uint3(max(float3(0), floor(voxelCenter)));
        float3 t = voxelCenter - float3(baseVoxelCoord);
        return lerp(
            lerp(
                lerp(
                    getBufferValue(tex, baseVoxelCoord + uint3(0, 0, 0)),
                    getBufferValue(tex, baseVoxelCoord + uint3(1, 0, 0)),
                    t.x
                ),
                lerp(
                    getBufferValue(tex, baseVoxelCoord + uint3(0, 1, 0)),
                    getBufferValue(tex, baseVoxelCoord + uint3(1, 1, 0)),
                    t.x
                ),
                t.y
            ),
            lerp(
                lerp(
                    getBufferValue(tex, baseVoxelCoord + uint3(0, 0, 1)),
                    getBufferValue(tex, baseVoxelCoord + uint3(1, 0, 1)),
                    t.x
                ),
                lerp(
                    getBufferValue(tex, baseVoxelCoord + uint3(0, 1, 1)),
                    getBufferValue(tex, baseVoxelCoord + uint3(1, 1, 1)),
                    t.x
                ),
                t.y
            ),
            t.z
        );
        // TODO: Student implementation ends here.
    }
}

public struct SharedTexture3D
{
    public uint3 size;
    public uint offset;
}

