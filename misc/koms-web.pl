#!/usr/bin/perl -w

use Inline Python => <<'END';
# EASY-INSTALL-ENTRY-SCRIPT: 'mitmproxy==4.0.4','console_scripts','mitmproxy'
__requires__ = 'mitmproxy==4.0.4'
import re
import sys
from pkg_resources import load_entry_point

if __name__ == '__main__':
    sys.argv[0] = re.sub(r'(-script\.pyw?|\.exe)?$', '', sys.argv[0])
    sys.exit(
        load_entry_point('mitmproxy==4.0.4', 'console_scripts', 'mitmproxy')()
    )
END
