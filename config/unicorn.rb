worker_processes 4
timeout 30

@app_path = '/home/rserver/proj/RMapServer/rmap_server'
listen "#{@app_path}/tmp/sockets/unicorn.sock", :backlog => 64
pid "#{@app_path}/tmp/pids/unicorn.pid"
