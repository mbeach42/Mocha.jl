train_fn = "data/train.hdf5"
train_source_fn = "data/train.txt"
if !isfile(train_fn)
  println("Data not found, use get-mnist.sh to generate HDF5 data")
  exit(1)
else
  open(train_source_fn, "w") do s
    println(s, train_fn)
  end
end

using Mocha

data_layer = HDF5DataLayer(source=train_source_fn, batch_size=64)
conv_layer = ConvolutionLayer(n_filter=20, kernel=(5,5), bottoms=[:data], tops=[:conv])
pool_layer = PoolingLayer(kernel=(2,2), stride=(2,2), bottoms=[:conv], tops=[:pool])
conv2_layer = ConvolutionLayer(n_filter=50, kernel=(5,5), bottoms=[:pool], tops=[:conv2])
pool2_layer = PoolingLayer(kernel=(2,2), stride=(2,2), bottoms=[:conv2], tops=[:pool2])
fc1_layer  = InnerProductLayer(output_dim=500, neuron=Neurons.ReLU(), bottoms=[:pool2], tops=[:ip1])
fc2_layer  = InnerProductLayer(output_dim=10, bottoms=[:ip1], tops=[:ip2])
loss_layer = SoftmaxLossLayer(bottoms=[:ip2,:label])

sys = System(CuDNNBackend())
init(sys)

net = Net(sys, [data_layer, conv_layer, pool_layer, conv2_layer, pool2_layer, fc1_layer, fc2_layer, loss_layer])
#net = Net(sys, [data_layer, fc2_layer, loss_layer])

params = SolverParameters(max_iter=10000, regu_coef=0.0005, base_lr=0.01, momentum=0.9,
    lr_policy=LRPolicy.Inv(0.0001, 0.75))
solver = SGD(params)
solve(solver, net)

shutdown(sys)
