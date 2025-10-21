
### sh3l vagrant
```
vagrant up
```

## check ip addr
```
vagrant ssh zoukaddoS -c "ip addr show eth1"
```

```
vagrant ssh zoukaddoSW -c "ip addr show eth1"
```


## check hostname
```
vagrant ssh zoukaddoSW -c "hostname"
```

```
vagrant ssh zoukaddoS -c "hostname"
```

## check k3s version
```
vagrant ssh zoukaddoS -c "k3s --version"
```

```
vagrant ssh zoukaddoSW -c "k3s --version"
```


## check nodes
```
vagrant ssh zoukaddoS -c "sudo kubectl get nodes -o wide"
```

