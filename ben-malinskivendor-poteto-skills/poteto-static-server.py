import argparse
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

parser = argparse.ArgumentParser()
parser.add_argument('port', type=int)
parser.add_argument('directory')
args = parser.parse_args()

class StaticServer(ThreadingHTTPServer):
    # Chromium requests module scripts/fonts in a burst; Python's default 5
    # pending connections caused ERR_CONNECTION_RESET before scripts initialized.
    request_queue_size = 256

StaticServer(('127.0.0.1', args.port), partial(SimpleHTTPRequestHandler, directory=args.directory)).serve_forever()
