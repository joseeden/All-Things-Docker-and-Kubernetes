
# From VMs to Containers

The traditional way of deploying applications was through *virtual machines or VMs*. The application would use the OS file system, the OS's resources and default packages installed. 

Virtual machines have been extremely efficient in maximizing the use of infrastructure. Instead of running one application on one physical machine, we could run multiple VMs on top of the *hypervisor* which sits on the physical machine.

<p align>
<img src="../../Images/us-5-vms.png">
</p>

While it has proved to be useful, it still has its own disadvantages:
- Each virtual machine would require its own operating system. - If you have three VMs sitting on the hypervisor, this would mean there's also three operating system running on top of the hypervisor
- The OS plus the required libraries of each VM takes up a chunk of space on the underlying machine

<p align>
<img src="../../Images/us-5-vm-containers.png">
</p>

**Enter containers.** To further optimize the usage of the server, container can be used to *virtualized the operating system.* Through containers, we won't need to run replicated OS. Regardless of how many containers we run on the machine, they will all use the same underlying operating system of the physical machine itself.

To facilitate the creation and management of the containers, we can use a container engine tool, such as **Docker.** 

Overall, the benefits of containers are:
- lightweight in nature
- provides better use of the resources
- develop applications that run consistently across platforms
- can be managed to scale well
