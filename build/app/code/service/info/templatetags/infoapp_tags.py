from django.template import Library, loader
from django.urls import resolve

import six

from ..models import InfoCategory as Category

register = Library()


@register.simple_tag()
def post_date_url(post, info_page):
    post_date = post.date
    url = info_page.url + info_page.reverse_subpage(
        'post_by_date_slug',
        args=(
            post_date.year,
            '{0:02}'.format(post_date.month),
            '{0:02}'.format(post_date.day),
            post.slug,
        )
    )
    return url


@register.inclusion_tag('info/components/categories_list.html', takes_context=True)
def categories_list(context):
    info_page = context['info_page']
    categories = Category.objects.all()
    return {'info_page': info_page, 'request': context['request'], 'categories': categories}


@register.inclusion_tag('info/components/post_categories_list.html', takes_context=True)
def post_categories(context):
    info_page = context['info_page']
    post = context['post']
    post_categories = post.categories.all()
    return {'info_page': info_page, 'post_categories': post_categories, 'request': context['request']}


@register.simple_tag(takes_context=True)
def canonical_url(context, post=None):
    if post and resolve(context.request.path_info).url_name == 'wagtail_serve':
        return context.request.build_absolute_uri(post_date_url(post, post.info_page))
    return context.request.build_absolute_uri()
