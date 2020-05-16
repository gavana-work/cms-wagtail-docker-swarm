from django.shortcuts import render

def handler400(request, exception):
    return render(request, 'default/400.html', status=400)

def handler403(request, exception):
    return render(request, 'default/403.html', status=403)

def handler404(request, exception):
    return render(request, 'default/404.html', status=404)

def handler500(request):
    return render(request, 'default/500.html', status=500)