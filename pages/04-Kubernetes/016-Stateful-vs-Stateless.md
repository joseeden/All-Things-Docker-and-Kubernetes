
# Stateless and Stateful

## Stateless Applications 

This means application that doesn't have a state and doesn't write any local files.

- also cannot keep local session 
- if same app is ran multiple times, it won't change state
- scales horizontally 
- session management is done outside the container
- files that need to be saved cannot be saved locally on the container

## Stateful Applications

Includes traditional databases such as PostgreSQL and MySQL which have database files that can't be split over multiple instances.

- cannot horizontally scale
- can be ran on a single container and scale vertically
- use volumes to save data