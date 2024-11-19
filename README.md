 # Setup talos cluster

This will not be perfect, it's for my own use and for learning :)

 ## Requirements
 * Hetzner customer :)
 * Domain at Hetzner, not needed, can be removed/adapted
 * packer for creating a talos base image
 * tofu (Should work with terraform too)
 * I use direnv to setup all the needed configuration variables

## Config

### Required environment variables:

```
# to use hcloud command in shell, optional
export HCLOUD_TOKEN=....
# for provider setup
export TF_VAR_hcloud_token=$HCLOUD_TOKEN

# provider setup
export HETZNER_DNS_API_TOKEN=...

# not needed, but useful when used with direnv in .envrc file
# tofu output -raw kubeconfig >kubeconfig; tofu output -raw talosconfig >talosconfig
export KUBECONFIG=kubeconfig
export TALOSCONFIG=talosconfig

```

### Input Parameter

see test.tfvars.sample

