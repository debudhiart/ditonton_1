import 'package:cached_network_image/cached_network_image.dart';
import 'package:ditonton/common/constants.dart';
import 'package:ditonton/presentation/pages/popular_tv_series_page.dart';
import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/presentation/pages/search_tv_series_page.dart';
import 'package:ditonton/presentation/pages/top_rated_tv_series_page.dart';
import 'package:ditonton/presentation/widgets/navigation_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ditonton/presentation/pages/tv_series_detail_page.dart';
import 'package:ditonton/presentation/provider/tv_series_list_notifier.dart';
import 'package:ditonton/domain/entities/tv_series.dart';

class HomeTVSeriesPage extends StatefulWidget {
  static const ROUTE_NAME = '/tv_series';
  @override
  _HomeTVSeriesPageState createState() => _HomeTVSeriesPageState();
}

class _HomeTVSeriesPageState extends State<HomeTVSeriesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => Provider.of<TVSeriesListNotifier>(context, listen: false)
          ..fetchOnTheAirTVSeries()
          ..fetchPopularTVSeries()
          ..fetchTopRatedTVSeries());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationDrawer(),
      appBar: AppBar(
        title: Text('Ditonton (TV Series)'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, SearchTVSeriesPage.ROUTE_NAME);
            },
            icon: Icon(Icons.search),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'On The Air Now',
                style: kHeading6,
              ),
              Consumer<TVSeriesListNotifier>(builder: (context, data, child) {
                final state = data.nowPlayingState;
                if (state == RequestState.Loading) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state == RequestState.Loaded) {
                  return TVSeriesList(data.onTheAirTVSeries);
                } else {
                  return Text('Failed');
                }
              }),
              _buildSubHeading(
                title: 'Popular',
                onTap: () => Navigator.pushNamed(
                    context, PopularTVSeriesPage.ROUTE_NAME),
              ),
              Consumer<TVSeriesListNotifier>(builder: (context, data, child) {
                final state = data.popularTVSeriesState;
                if (state == RequestState.Loading) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state == RequestState.Loaded) {
                  return TVSeriesList(data.popularTVSeries);
                } else {
                  return Text('Failed');
                }
              }),
              _buildSubHeading(
                title: 'Top Rated',
                onTap: () => Navigator.pushNamed(
                    context, TopRatedTVSeriesPage.ROUTE_NAME),
              ),
              Consumer<TVSeriesListNotifier>(builder: (context, data, child) {
                final state = data.topRatedTVSeriesState;
                if (state == RequestState.Loading) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state == RequestState.Loaded) {
                  return TVSeriesList(data.topRatedTVSeries);
                } else {
                  return Text('Failed');
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  Row _buildSubHeading({required String title, required Function() onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: kHeading6,
        ),
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [Text('See More'), Icon(Icons.arrow_forward_ios)],
            ),
          ),
        ),
      ],
    );
  }
}

class TVSeriesList extends StatelessWidget {
  final List<TVSeries> tvSeries;

  TVSeriesList(this.tvSeries);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final atvSeries = tvSeries[index];
          return Container(
            padding: const EdgeInsets.all(8),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  TVSeriesDetailPage.ROUTE_NAME,
                  arguments: atvSeries.id,
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                child: CachedNetworkImage(
                  imageUrl: '$BASE_IMAGE_URL${atvSeries.posterPath}',
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
          );
        },
        itemCount: tvSeries.length,
      ),
    );
  }
}
