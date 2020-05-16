from __future__ import unicode_literals

from django.db import models
from modelcluster.fields import ParentalKey
from modelcluster.models import ClusterableModel

from wagtail.admin.edit_handlers import (
    FieldPanel,
    FieldRowPanel,
    InlinePanel,
    MultiFieldPanel,
    PageChooserPanel,
    StreamFieldPanel,
)
from wagtail.images.edit_handlers import ImageChooserPanel
from wagtail.core.fields import RichTextField, StreamField
from wagtail.contrib.forms.models import AbstractEmailForm, AbstractFormField

from datetime import date
from wagtail.admin.mail import send_mail
from default.blocks import BaseStreamBlock

######################################################################

class FormField(AbstractFormField):
    page = ParentalKey('ContactPage', related_name='custom_form_fields')

class ContactPage(AbstractEmailForm):

    template = 'contact/contact_page.html'
    subtitle = models.CharField(max_length = 255, blank=True)
    image = models.ForeignKey(
        'wagtailimages.Image',
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name='+',
    )
    thanks_title = models.CharField(max_length = 255, blank=True, verbose_name="Thanks page title",)
    thanks_subtitle = models.CharField(max_length = 255, blank=True, verbose_name="Thanks page subtitle",)
    thanks_image = models.ForeignKey(
        'wagtailimages.Image',
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name='+',
        verbose_name="Thanks page image",
    )
    thanks_body = StreamField(
        BaseStreamBlock(), verbose_name="Thanks page body", blank=True
    )
    
    content_panels = AbstractEmailForm.content_panels + [
        FieldPanel('subtitle'),
        ImageChooserPanel('image'),
        InlinePanel('custom_form_fields', label="Form fields"),
        FieldPanel('thanks_title'),
        FieldPanel('thanks_subtitle'),
        ImageChooserPanel('thanks_image'),
        StreamFieldPanel('thanks_body'),
        MultiFieldPanel([
            FieldRowPanel([
                FieldPanel('from_address', classname="col6"),
                FieldPanel('to_address', classname="col6"),
            ]),
        ], "Email Configuration"),
    ]

    def get_form_fields(self):
        return self.custom_form_fields.all()

    def send_mail(self, form):

        addresses = []
        addresses.append(self.to_address)
        submitted_date_str = date.today().strftime('%x')
        subject = 'Contact Request - ' + submitted_date_str
        content = ['Submission content below -\n', ]

        for field in form:
            # add the value of each field as a new line
            value = field.value()
            if isinstance(value, list):
                value = ', '.join(value)
            content.append('{}: {}'.format(field.label, value))

        # Content is joined with a new line to separate each text line
        content = '\n'.join(content)

        # wagtail.wagtailadmin.utils - send_mail function is called
        # This function extends the Django default send_mail function
        send_mail(subject, content, addresses, self.from_address)