"""Simple deterministic movement along a route for testing the simulation."""
def movement_step(path, current_index):
    if not path:
        return {"node":None,"index":current_index,"finished":True}
    idx=max(0,min(int(current_index),len(path)-1))
    return {"node":path[idx],"index":idx,"finished":idx>=len(path)-1}

def simulate_movement(path):
    return [movement_step(path,i) for i in range(len(path))]
