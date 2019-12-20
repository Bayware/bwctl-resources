import os

from setuptools import setup


def read(filename):
    try:
        with open(os.path.join(os.path.dirname(__file__), filename)) as f:
            return f.read()
    except IOError as err:
        print("I/O error while reading {0!r} ({1!s}): {2!s}".format(filename, err.errno, err.strerror))
        return "0.0.1"


setup(
    name='bwctl_resources',
    version=read('version.txt').strip(),
    author='Bayware',
    author_email='bwctl@bayware.io',
    description='Bayware Command Line Toolkit Resources',
    long_description=read('README.md'),
    license="GNU GPLv3",
    url='https://www.bayware.io',
    platforms='Posix;',
    packages=['bwctl_resources', 'bwctl_resources.ansible', 'bwctl_resources.terraform'],
    include_package_data=True
)
