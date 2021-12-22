import click
import subprocess

@click.group()
def cli():
    pass

@click.command("pull-if-doesnt-exist")
@click.argument("image")
def pull_if_doesnt_exist(image):
    images = subprocess.check_output([
        "docker",
        "images",
        image
    ]).decode("utf8").rstrip().split("\n")[1:]
    if len(images) < 1:
        print(f"{image} not found, pulling...")
        subprocess.check_call([
            "docker",
            "pull",
            image
        ])
cli.add_command(pull_if_doesnt_exist)

if __name__ == '__main__':
    cli()
