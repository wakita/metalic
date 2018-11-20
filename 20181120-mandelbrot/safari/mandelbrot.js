class Uniform {
    constructor(float32Array) {
        if (float32Array && float32Array.length != 64) {
            console.log("Incorrect backing store for Uniform");
            return;
        }

        this.array = float32Array || new Float32Array(64);
    }
    // Layout is C: [0-3]
    get buffer() {
        return this.array;
    }
    get C() {
      return this.array.subarray(0, 4);
    }
    set C(v) {
      for (let i = 0; i < 4; i++) this.array[i] = v[i];
    }
    copyValuesTo(buffer) {
        var bufferData = new Float32Array(buffer.contents);
        for (let i = 0; i < 4; i++) bufferData[i] = this.array[i];
    }
}

const vertexData = new Float32Array(
[
    -1, -1,
     1, -1,
    -1,  1,
     1,  1 ]);

let gpu;
let commandQueue;
let renderPassDescriptor;
let renderPipelineState;

const NumActiveUniformBuffers = 1;
let uniforms = new Array(NumActiveUniformBuffers);
let uniformBuffers = new Array(NumActiveUniformBuffers);
let currentUniformBufferIndex = 0;

window.addEventListener("load", init, false);

function init() {
    if (!checkForWebMetal()) {
        return;
    }

    let canvas = document.querySelector("canvas");
    let canvasSize = canvas.getBoundingClientRect();
    canvas.width = canvasSize.width;
    canvas.height = canvasSize.height;

    gpu = canvas.getContext("webmetal");
    commandQueue = gpu.createCommandQueue();

    let library = gpu.createLibrary(document.getElementById("library").text);
    let vertexFunction = library.functionWithName("vs");
    let fragmentFunction = library.functionWithName("fs");

    if (!library || !fragmentFunction || !vertexFunction) {
        return;
    }

    let pipelineDescriptor = new WebMetalRenderPipelineDescriptor();
    pipelineDescriptor.vertexFunction = vertexFunction;
    pipelineDescriptor.fragmentFunction = fragmentFunction;
    // NOTE: Our API proposal has these values as enums, not constant numbers.
    // We haven't got around to implementing the enums yet.
    pipelineDescriptor.colorAttachments[0].pixelFormat = gpu.PixelFormatBGRA8Unorm;

    renderPipelineState = gpu.createRenderPipelineState(pipelineDescriptor);

    for (let i = 0; i < NumActiveUniformBuffers; i++) {
        let uniform = new Uniform();
        uniform.C = new Float32Array([-2.0, -2.0, 2.0, 2.0 ]);
        uniforms[i] = uniform;
        uniformBuffers[i] = gpu.createBuffer(uniform.buffer);
    }

    renderPassDescriptor = new WebMetalRenderPassDescriptor();
    // NOTE: Our API proposal has some of these values as enums, not constant numbers.
    // We haven't got around to implementing the enums yet.
    renderPassDescriptor.colorAttachments[0].loadAction = gpu.LoadActionClear;
    renderPassDescriptor.colorAttachments[0].storeAction = gpu.StoreActionStore;
    renderPassDescriptor.colorAttachments[0].clearColor = [0.0, 0.0, 0.0, 1.0];

    vertexBuffer = gpu.createBuffer(vertexData);
    render();

    canvas.addEventListener('click', function (evt) {
      setTarget(canvas, evt);
    }, false);
}

function render() {
    updateUniformData(currentUniformBufferIndex);

    let commandBuffer = commandQueue.createCommandBuffer();

    let drawable = gpu.nextDrawable();

    renderPassDescriptor.colorAttachments[0].texture = drawable.texture;

    let commandEncoder = commandBuffer.createRenderCommandEncoderWithDescriptor(renderPassDescriptor);
    commandEncoder.setRenderPipelineState(renderPipelineState);
    commandEncoder.setVertexBuffer(vertexBuffer, 0, 0);
    commandEncoder.setVertexBuffer(uniformBuffers[currentUniformBufferIndex], 0, 1);
    commandEncoder.setFragmentBuffer(uniformBuffers[currentUniformBufferIndex], 0, 0);

    // NOTE: Our API proposal uses the enum value "triangle" here. We haven't got around to implementing the enums yet.
    commandEncoder.drawPrimitives(gpu.PrimitiveTypeTriangleStrip, 0, 4);

    commandEncoder.endEncoding();
    commandBuffer.presentDrawable(drawable);
    commandBuffer.commit();

    currentUniformBufferIndex = (currentUniformBufferIndex + 1) % NumActiveUniformBuffers;
    requestAnimationFrame(render);
}

const poi = [ 0.0, 0.0 ];
const α = 0.999;
const N = 60.0;
const αN = Math.pow(α, N);

function setTarget(canvas, evt) {
  let C = uniforms[0].C;
  let rect = canvas.getBoundingClientRect();
  let pos = [ evt.clientX - rect.left, rect.height - (evt.clientY - rect.top) ];
  poi[0] = ((rect.width  - pos[0]) * C[0] + pos[0] * C[2]) / rect.width;
  poi[1] = ((rect.height - pos[1]) * C[1] + pos[1] * C[3]) / rect.height;
  console.log('rect:', [rect.width, rect.height], 'pos:', pos, 'poi:', poi);
}

var logN = 0;

function updateUniformData(index) {
    let C = uniforms[index].C;
    let px = poi[0], py = poi[1];
    let dx = (C[2] - C[0]) * αN, dy = (C[3] - C[1]) * αN;
    let c1x = px - dx / 2, c1y = py - dy / 2;
    let c2x = px + dx / 2, c2y = py + dy / 2;
    C[0] = [ C[0] * ((N - 1) / N) + c1x * (1 / N)];
    C[1] = [ C[1] * ((N - 1) / N) + c1y * (1 / N)];
    C[2] = [ C[2] * ((N - 1) / N) + c2x * (1 / N)];
    C[3] = [ C[3] * ((N - 1) / N) + c2y * (1 / N)];

    uniforms[index].copyValuesTo(uniformBuffers[index]);
}
