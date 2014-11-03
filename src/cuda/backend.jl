export CuDNNBackend

type CuDNNBackend <: Backend
  initialized:: Bool
  cu_ctx     :: CUDA.CuContext
  cublas_ctx :: CuBLAS.Handle
  cudnn_ctx  :: CuDNN.Handle

  CuDNNBackend() = new(false) # everything will be initialized later
end

function init(backend::CuDNNBackend)
  @assert backend.initialized == false

  CUDA.init()
  dev = CUDA.CuDevice(0)
  backend.cu_ctx = CUDA.create_context(dev)
  backend.cublas_ctx = CuBLAS.create()
  backend.cudnn_ctx = CuDNN.create()
  backend.initialized = true
end

function shutdown(backend::CuDNNBackend)
  @assert backend.initialized == true

  # NOTE: destroy should be in reverse order of init
  CuDNN.destroy(backend.cudnn_ctx)
  CuBLAS.destroy(backend.cublas_ctx)
  CUDA.destroy(backend.cu_ctx)
  backend.initialized = false
end


