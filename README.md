# SSTable Sideloader Interactive Scenario

## Start this hands-on lab:

Start two ssh sessions to your VM running this scenario, one regular SSH, the other one used for keeping a SSH tunneling open (the session will hang while the tunnel is running):

```
ssh -i ~/.ssh/vm_key ubuntu@<VM_public_ip>
ssh -i ~/.ssh/vm_key -L 8080:localhost:8080 ubuntu@<VM_public_ip>
```

