from wagtail.images.blocks import ImageChooserBlock
from wagtail.embeds.blocks import EmbedBlock
from wagtail.core.blocks import (
    CharBlock, ChoiceBlock, RichTextBlock, StreamBlock, StructBlock, TextBlock, RawHTMLBlock,
)

from wagtail.contrib.table_block.blocks import TableBlock

######################################################################

CODE_CHOICES = [
    ('bash', 'bash'),
    ('python', 'python'),
    ('docker', 'docker'),
    ('yaml', 'yaml'),
    ('sql', 'sql'),
    ('css', 'css'),
    ('markup', 'markup'),
    ('javascript', 'javascript'),
    ('shell-session', 'shell-session'),
    ('basic', 'basic'),
    ('batch', 'batch'),
    ('c', 'c'),
    ('cpp', 'cpp'),
    ('clike', 'clike'),
    ('git', 'git'),
    ('http', 'http'),
    ('hpkp', 'hpkp'),
    ('hsts', 'hsts'),
    ('java', 'java'),
    ('nginx', 'nginx'),
    ('plsql', 'plsql'),
    ('powershell', 'powershell'),
    ('puppet', 'puppet'),
    ('regex', 'regex'),
    ('vbnet', 'vbnet'),
    ('visual-basic', 'visual-basic'),
]

class CodeBlock(StructBlock):
    language = ChoiceBlock(choices=CODE_CHOICES, default="shell")
    text = TextBlock()
    class Meta:
        template = "default/blocks/code_block.html"
        icon = "openquote"
        label = "Code Block"

class ImageBlock(StructBlock):
    image = ImageChooserBlock(required=True)
    caption = CharBlock(required=False)
    class Meta:
        icon = 'image'
        template = "default/blocks/image_block.html"

class BaseStreamBlock(StreamBlock):
    paragraph_block = RichTextBlock(
        icon="fa-paragraph",
        template="default/blocks/paragraph_block.html"
    )
    embed_block = EmbedBlock(
        icon="fa-s15",
        template="default/blocks/embed_block.html")
    html_block = RawHTMLBlock()
    table_block = TableBlock()
    image_block = ImageBlock()
    code_block = CodeBlock()
    class Meta:
        required = False