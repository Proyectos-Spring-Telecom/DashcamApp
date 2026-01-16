import 'package:dashboardpro/dashboardpro.dart';

class PaginationDataGrid extends StatefulWidget {
  const PaginationDataGrid({super.key});

  @override
  State<PaginationDataGrid> createState() => _PaginationDataGridState();
}

class _PaginationDataGridState extends State<PaginationDataGrid> {
  final PagingController _pagingController = PagingController(firstPageKey: 1);

  // search bar
  TextEditingController searchController = TextEditingController();

  // Initial Selected Value
  int pageSize = 10;
  int page = 1;

  // List of items in our dropdown menu
  var items = [10, 20, 30, 40, 50];

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      if (Responsive.isDesktop(context) || Responsive.isTablet(context)) {
        final newItems = await getData(
            page: page, pageSize: pageSize, searchText: searchController.text);

        if (!mounted) {
          return;
        }

        if (newItems != null) {
          _pagingController.appendLastPage(newItems);
        } else {
          _pagingController.appendLastPage([]);
        }
      } else {
        final newItems = await getData(
            page: pageKey, pageSize: 10, searchText: searchController.text);

        if (!mounted) {
          return;
        }

        if (newItems != null) {
          final isLastPage = newItems.length < 10;
          if (isLastPage) {
            _pagingController.appendLastPage(newItems);
          } else {
            final nextPageKey = pageKey + 1;
            _pagingController.appendPage(newItems, nextPageKey);
          }
        } else {
          _pagingController.appendLastPage([]);
        }
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Responsive(
        mobile: mobileView(), desktop: desktopView(), tablet: tabView());
  }

  Widget desktopView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: SizeConfig.spaceHeight),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: SizeConfig.padding * 2),
          child: SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Restrooms",
                  style: TextStyle(fontSize: SizeConfig.spaceHeight),
                ),
                SizedBox(
                  height: 40,
                  width: MediaQuery.of(context).size.width / 5,
                  child: TextFormField(
                    controller: searchController,
                    onEditingComplete: () {
                      Future.delayed(const Duration(microseconds: 1000), () {
                        setState(() {
                          _pagingController.refresh();
                        });
                      });
                    },
                    onFieldSubmitted: (v) {
                      Future.delayed(const Duration(microseconds: 1000), () {
                        setState(() {
                          _pagingController.refresh();
                        });
                      });
                    },
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: "Search..",
                      contentPadding: EdgeInsets.only(left: SizeConfig.padding),
                      suffixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: SizeConfig.padding * 2),
          child: const SizedBox(
            height: 50,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text("Id"),
                ),
                Expanded(
                  flex: 3,
                  child: Text("Name"),
                ),
                Expanded(
                  flex: 1,
                  child: Text("City"),
                ),
                Expanded(
                  flex: 1,
                  child: Center(child: Text("status")),
                ),
                Expanded(
                  flex: 1,
                  child: Center(child: Text("Action")),
                ),
              ],
            ),
          ),
        ),
        const Divider(),
        SizedBox(
          height: MediaQuery.of(context).size.height / 1.9,
          child: PagedListView.separated(
            shrinkWrap: true,
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate(
              firstPageErrorIndicatorBuilder: (context) => Center(
                child: Text("${_pagingController.error}"),
              ),
              itemBuilder: (context, item, index) {
                dynamic data = item;
                return Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: SizeConfig.padding * 2),
                  child: SizedBox(
                    height: 40,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text("${data['id']}"),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text("${data['name']}"),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text("${data['city']}"),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: CircleAvatar(
                              radius: 5,
                              backgroundColor: data['approved']
                                  ? AppColors.success
                                  : AppColors.danger,
                            ),
                          ),
                        ),
                        const Expanded(
                          flex: 1,
                          child: Center(child: Icon(Icons.more_vert_outlined)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            separatorBuilder: (BuildContext context, int index) {
              return const Divider();
            },
          ),
        ),
        const Divider(),
        SizedBox(
          height: 50,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeConfig.padding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text("Show"),
                    SizedBox(width: SizeConfig.spaceWidth),
                    DropdownButton(
                      // Initial Value
                      value: pageSize,

                      // Down Arrow Icon
                      icon: const Icon(Icons.keyboard_arrow_down),

                      // Array list of items
                      items: items.map((items) {
                        return DropdownMenuItem(
                          value: items,
                          child: Text(items.toString()),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          pageSize = newValue!;
                          _pagingController.refresh();
                        });
                      },
                    ),
                    SizedBox(width: SizeConfig.spaceWidth),
                    const Text("entries"),
                  ],
                ),
                SizedBox(
                  height: 50,
                  width: MediaQuery.of(context).size.width / 5,
                  child: NumberPagination(
                    onPageChanged: (int pageNumber) {
                      setState(() {
                        page = pageNumber;
                        _pagingController.refresh();
                      });
                    },
                    fontSize: 12.0,
                    pageTotal: 20,
                    pageInit: 1, // picked number when init page
                    threshold: 3,
                    controlButton: const SizedBox(),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget tabView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: SizeConfig.spaceHeight),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: SizeConfig.padding * 2),
          child: SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Restrooms",
                  style: TextStyle(fontSize: SizeConfig.spaceHeight),
                ),
                SizedBox(
                  height: 40,
                  width: MediaQuery.of(context).size.width / 5,
                  child: TextFormField(
                    controller: searchController,
                    onEditingComplete: () {
                      Future.delayed(const Duration(microseconds: 1000), () {
                        setState(() {
                          _pagingController.refresh();
                        });
                      });
                    },
                    onFieldSubmitted: (v) {
                      Future.delayed(const Duration(microseconds: 1000), () {
                        setState(() {
                          _pagingController.refresh();
                        });
                      });
                    },
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: "Search..",
                      contentPadding: EdgeInsets.only(left: SizeConfig.padding),
                      suffixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: SizeConfig.padding * 2),
          child: const SizedBox(
            height: 50,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text("Id"),
                ),
                Expanded(
                  flex: 3,
                  child: Text("Name"),
                ),
                Expanded(
                  flex: 1,
                  child: Center(child: Text("status")),
                ),
                Expanded(
                  flex: 1,
                  child: Center(child: Text("Action")),
                ),
              ],
            ),
          ),
        ),
        const Divider(),
        SizedBox(
          height: MediaQuery.of(context).size.height / 1.9,
          child: PagedListView.separated(
            shrinkWrap: true,
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate(
              firstPageErrorIndicatorBuilder: (context) => Center(
                child: Text("${_pagingController.error}"),
              ),
              itemBuilder: (context, item, index) {
                dynamic data = item;
                return Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: SizeConfig.padding * 2),
                  child: SizedBox(
                    height: 40,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text("${data['id']}"),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text("${data['name']}"),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: CircleAvatar(
                              radius: 5,
                              backgroundColor: data['approved']
                                  ? AppColors.success
                                  : AppColors.danger,
                            ),
                          ),
                        ),
                        const Expanded(
                          flex: 1,
                          child: Center(child: Icon(Icons.more_vert_outlined)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            separatorBuilder: (BuildContext context, int index) {
              return const Divider();
            },
          ),
        ),
        const Divider(),
        SizedBox(
          height: 50,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeConfig.padding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text("Show"),
                    SizedBox(width: SizeConfig.spaceWidth),
                    DropdownButton(
                      // Initial Value
                      value: pageSize,

                      // Down Arrow Icon
                      icon: const Icon(Icons.keyboard_arrow_down),

                      // Array list of items
                      items: items.map((items) {
                        return DropdownMenuItem(
                          value: items,
                          child: Text(items.toString()),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          pageSize = newValue!;
                          _pagingController.refresh();
                        });
                      },
                    ),
                    SizedBox(width: SizeConfig.spaceWidth),
                    const Text("entries"),
                  ],
                ),
                SizedBox(
                  height: 50,
                  width: MediaQuery.of(context).size.width / 5,
                  child: NumberPagination(
                    onPageChanged: (int pageNumber) {
                      setState(() {
                        page = pageNumber;
                        _pagingController.refresh();
                      });
                    },
                    fontSize: 12.0,
                    pageTotal: 20,
                    pageInit: 1, // picked number when init page
                    threshold: 3,
                    controlButton: const SizedBox(),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget mobileView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: SizeConfig.spaceHeight),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: SizeConfig.padding * 2),
          child: SizedBox(
            height: 40,
            width: MediaQuery.of(context).size.width,
            child: TextFormField(
              controller: searchController,
              onEditingComplete: () {
                Future.delayed(const Duration(microseconds: 1000), () {
                  setState(() {
                    _pagingController.refresh();
                  });
                });
              },
              onFieldSubmitted: (v) {
                Future.delayed(const Duration(microseconds: 1000), () {
                  setState(() {
                    _pagingController.refresh();
                  });
                });
              },
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: "Search..",
                contentPadding: EdgeInsets.only(left: SizeConfig.padding),
                suffixIcon: const Icon(Icons.search),
              ),
            ),
          ),
        ),
        const Divider(),
        SizedBox(
          height: MediaQuery.of(context).size.height - 250,
          child: PagedListView.separated(
            shrinkWrap: true,
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate(
              firstPageErrorIndicatorBuilder: (context) => Center(
                child: Text("${_pagingController.error}"),
              ),
              itemBuilder: (context, item, index) {
                dynamic data = item;
                return Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: SizeConfig.padding * 2),
                  child: ListTile(title: Text("${data['name']}")),
                );
              },
            ),
            separatorBuilder: (BuildContext context, int index) {
              return const Divider();
            },
          ),
        ),
      ],
    );
  }

  Future<dynamic> getData(
      {required int page,
      required int pageSize,
      required String searchText}) async {
    final response = await Dio().get(
        "https://refugerestrooms.org/api/v1/restrooms/search?page=$page&per_page=$pageSize&offset=0&query=$searchText");
    return response.data;
  }
}
