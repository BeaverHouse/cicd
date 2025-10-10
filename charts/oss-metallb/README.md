# MetalLB

MetalLB is a load balancer implementation for bare-metal Kubernetes environments.
I use it to expose services to the internet via [Layer 2 mode](https://metallb.universe.tf/concepts/layer2/).

**Note that MetalLB will not work on most cloud providers.**

## Resources

- `ipconfig.yaml`: Configures the IP pool & L2 advertisement for MetalLB.
- `namespace.yaml`: Creates the metallb-system namespace.
  - MetalLB requires privileged permissions to function correctly.
