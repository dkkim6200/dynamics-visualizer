using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Newtonsoft.Json;
using Unity.Collections;

public class SphericalDepthVisualizer : MonoBehaviour
{

    public TextAsset DepthFramesAsset;
    [Range(1, 30)]
    public int FrameRate = 15;

    private List<List<float>> _depthFrames;
    private Texture2D _depthTexture;
    private NativeArray<float> _depthNA;

    private Renderer _renderer;

    private Mesh _mesh;
    private Vector3[] _vertices;
    private Color32[] _colors;
    private int[] _indices;

    private float lastUpdateTime = 0f;
    private int frameIndex = 0;

    // Start is called before the first frame update
    void Start()
    {
        _depthFrames = JsonConvert.DeserializeObject<List<List<float>>>(DepthFramesAsset.text);

        _depthTexture = new Texture2D(640, 480, TextureFormat.RFloat, false);
        _depthNA = new NativeArray<float>(_depthFrames[0].ToArray(), Allocator.Persistent);
        _depthTexture.LoadRawTextureData(_depthNA);
        _depthTexture.Apply();

        _renderer = GetComponent<Renderer>();
        _renderer.material.SetTexture("_DepthTex", _depthTexture);

        _mesh = new Mesh();
        _mesh.indexFormat = UnityEngine.Rendering.IndexFormat.UInt32;

        const int numPoints = 640 * 480;

        _vertices = new Vector3[numPoints];
        _colors = new Color32[numPoints];
        _indices = new int[numPoints];

        //Initialization of index list
        for (int i = 0; i < numPoints; i++)
        {
            _colors[i] = new Color32(1, 1, 1, 1);
            _indices[i] = i;
        }

        _vertices[0] = new Vector3(1, 1, 1);
        _vertices[1] = new Vector3(-1, 1, 1);
        _vertices[2] = new Vector3(1, -1, 1);
        _vertices[3] = new Vector3(-1, -1, 1);
        _vertices[4] = new Vector3(1, 1, -1);
        _vertices[5] = new Vector3(-1, 1, -1);
        _vertices[6] = new Vector3(1, -1, -1);
        _vertices[7] = new Vector3(-1, -1, -1);

        _mesh.vertices = _vertices;
        _mesh.colors32 = _colors;
        _mesh.SetIndices(_indices, MeshTopology.Points, 0);
        _mesh.RecalculateBounds();

        gameObject.GetComponent<MeshFilter>().mesh = _mesh;
    }

    void OnDestroy()
    {
        _depthNA.Dispose();
    }

    // Update is called once per frame
    void Update()
    {
        if (Time.timeSinceLevelLoad - lastUpdateTime > 1f / FrameRate)
        {
            lastUpdateTime = Time.timeSinceLevelLoad;
            frameIndex++;
            frameIndex %= _depthFrames.Count;

            _depthNA.CopyFrom(_depthFrames[frameIndex].ToArray());
            _depthTexture.LoadRawTextureData(_depthNA);
            _depthTexture.Apply();
        }
    }
}
