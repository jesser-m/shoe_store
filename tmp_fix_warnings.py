import os

def strip_bom(data):
    if data.startswith(b'\xef\xbb\xbf'):
        return data[3:]
    return data

# Fix user_service.dart - remove dart:convert
with open('lib/services/user_service.dart', 'rb') as f:
    content = f.read()
content = strip_bom(content)
content = content.replace(b"import 'dart:convert';\n", b'')
with open('lib/services/user_service.dart', 'wb') as f:
    f.write(content)
print('user_service.dart fixed')

# Fix admin_order_screen.dart - remove unused _statusColor and _statusLabel
with open('lib/screens/admin/admin_order_screen.dart', 'rb') as f:
    content = f.read()
content = strip_bom(content)

# Find and remove the two unused static methods
old_block = b"""  static Color _statusColor(String s) => {
        'pending': Colors.orange,
        'paid': Colors.blue,
        'shipped': Colors.indigo,
        'delivered': Colors.green,
        'cancelled': Colors.red,
      }[s] ??
      Colors.grey;

  static String _statusLabel(String s) => {
        'pending': 'En attente',
        'paid': 'Paye',
        'shipped': 'Expedie',
        'delivered': 'Livre',
        'cancelled': 'Annule',
      }[s] ??
      s;

"""

if old_block in content:
    content = content.replace(old_block, b'')
    print('admin_order_screen.dart fixed (removed unused methods)')
else:
    print('admin_order_screen.dart: block not found, checking with accent variations...')
    # Try with accented characters
    old_block2 = b"""  static Color _statusColor(String s) => {
        'pending': Colors.orange,
        'paid': Colors.blue,
        'shipped': Colors.indigo,
        'delivered': Colors.green,
        'cancelled': Colors.red,
      }[s] ??
      Colors.grey;

  static String _statusLabel(String s) => {
        'pending': 'En attente',
        'paid': 'Pay\u00e9',
        'shipped': 'Exp\u00e9di\u00e9',
        'delivered': 'Livr\u00e9',
        'cancelled': 'Annul\u00e9',
      }[s] ??
      s;

"""
    if old_block2 in content:
        content = content.replace(old_block2, b'')
        print('admin_order_screen.dart fixed (removed unused methods with accents)')
    else:
        print('admin_order_screen.dart: still not found, skipping')

with open('lib/screens/admin/admin_order_screen.dart', 'wb') as f:
    f.write(content)

print('Done!')
