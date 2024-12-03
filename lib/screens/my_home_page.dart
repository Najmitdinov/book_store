import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/book.dart';

import '../widgets/app_drawer.dart';
import '../widgets/books_details.dart';
import '../widgets/costume_search_bar.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool showSearchInput = false;

  @override
  Widget build(BuildContext context) {
    final bookData = Provider.of<Book>(context);

    // final category = Provider.of<Category>(context);
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        // title: showSearchInput
        //     ? Container(
        //         alignment: Alignment.center,
        //         width: double.infinity,
        //         height: 40,
        //         decoration: BoxDecoration(
        //           borderRadius: BorderRadius.circular(9),
        //           color: Colors.white,
        //         ),
        //         child: Row(
        //           children: [
        //             Expanded(
        //               child: const TextField(
        //                 decoration: InputDecoration(
        //                   labelText: 'Search',
        //                   floatingLabelBehavior: FloatingLabelBehavior.never,
        //                   border: OutlineInputBorder(
        //                     borderSide: BorderSide.none,
        //                   ),
        //                   contentPadding: EdgeInsets.only(left: 10),
        //                 ),
        //               ),
        //             ),
        //             IconButton(
        //               onPressed: () {

        //               },
        //               icon: const Icon(
        //                 Icons.search,
        //                 color: Colors.black,
        //               ),
        //             ),
        //           ],
        //         ),
        //       )
        //     : Container(),
        backgroundColor: Colors.black,
        centerTitle: true,
        actions: [
          IconButton(
            padding: const EdgeInsets.all(0),
            onPressed: () {
              // setState(() {
              //   showSearchInput = !showSearchInput;
              // });
              showSearch(
                context: context,
                delegate: CostumSeatchDelegate(bookData),
              );
            },
            icon: Icon(
              showSearchInput ? Icons.close : Icons.search_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          const Padding(
            padding: EdgeInsets.only(right: 10),
            child: CircleAvatar(
              radius: 15,
              backgroundImage: NetworkImage(
                'https://media.istockphoto.com/id/1476170969/photo/portrait-of-young-man-ready-for-job-business-concept.webp?a=1&b=1&s=612x612&w=0&k=20&c=-F_sZl6saA5wNg2OTdO3zcHZ3aQ2ml9Ru-PXGcUDdHg=',
              ),
            ),
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (ctx, innerBoxIsScrolled) {
          return [
            const SliverAppBar(
              pinned: false,
              floating: true,
              snap: true,
              toolbarHeight: 100,
              elevation: 0,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.black,
              title: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Salom, hurmatli foydalanuvchi',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Book store ga xush kelibsiz!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ];
        },
        body: const SingleChildScrollView(
          child: BooksDetails(),
        ),
      ),
    );
  }
}
