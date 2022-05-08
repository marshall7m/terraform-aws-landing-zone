from setuptools import setup, find_packages

install_requires = [
    'pytest-terra-fixt @ git+https://github.com/marshall7m/pytest-terra-fixt@v0.1.0#egg=pytest-terra-fixt'
]
setup(
    name="terraform-aws-landing-zone",
    install_requires=install_requires,
    packages=find_packages()
)