# MetalLB

MetalLB is a load balancer implementation for bare-metal Kubernetes environments.
I use it to expose services to the internet via [Layer 2 mode](https://metallb.universe.tf/concepts/layer2/).

### Layer 2 vs Layer 3 (BGP) Mode

- **Layer 2**: One node owns the IP and responds to ARP. Simple setup, but slight delay during failover.
- **Layer 3 (BGP)**: Peers with routers via BGP for traffic distribution. More complex, but enables true load balancing.
- L2 is recommended for home/small setups; BGP for large-scale/high-availability environments.

**Note that MetalLB will not work on most cloud providers.**

## Resources

- `ipconfig.yaml`: Configures the IP pool & L2 advertisement for MetalLB.
- `namespace.yaml`: Creates the metallb-system namespace.
  - MetalLB requires privileged permissions to function correctly.

## Documentation

- [MetalLB Installation](https://metallb.universe.tf/installation/)
- [MetalLB Configuration](https://metallb.universe.tf/configuration/)
