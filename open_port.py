import socket;

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM);

s.bind(('0.0.0.0', 1013));
s.listen(1);

conn, addr = s.accept();

print('Connected with ' + addr[0] + ':' + str(addr[1]))
