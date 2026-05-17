from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from .services import MenuService
from .serializers import MenuCatalogSerializer

class MenuCategoriesView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        """
        Retrieve menu categories with their items.
        Supports search and category filtering via query parameters.
        """
        search = request.query_params.get('search')
        category = request.query_params.get('category')

        try:
            catalogs = MenuService.get_catalogs(search=search, category_filter=category)
            # Pass request into serializer context so nested serializers can build absolute media URLs
            serializer = MenuCatalogSerializer(catalogs, many=True, context={'request': request})
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Exception as e:
            # Log the error
            return Response(
                {"error": "Unable to load the menu at this time. Please try again later."},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
