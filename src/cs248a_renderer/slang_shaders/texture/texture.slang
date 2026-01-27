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

    /**
     * Sample the texture at the given uvw coordinates using nearest neighbor interpolation.
     * @param tex The texture to sample.
     * @param uvw The uvw coordinates to sample the texture at.
     * @return The sampled value.
     */
    public T pointSample(SharedTexture3D tex, float3 uvw)
    {
        // TODO: Student implementation starts here.

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
        float3 baseVoxelCoord = uvw * float3(tex.size);
        T sample = T(0);
        for (float i = -0.5; i < 1; i+=0.5) {
            for (float j = -0.5; j < 1; j+=0.5) {
                for (float k = -0.5; k < 1; k+=0.5) {
                    if (i == 0.0 && j == 0.0 && k == 0.0) {
                        continue;
                    }
                    sample = sample.add(pointSample(tex, float3((baseVoxelCoord.x + i), (baseVoxelCoord.y + j), (baseVoxelCoord.z + k)) / tex.size)).div(T(8));
                }
            }
        }
        return sample
        // TODO: Student implementation ends here.
    }
}

public struct SharedTexture3D
{
    public uint3 size;
    public uint offset;
}

