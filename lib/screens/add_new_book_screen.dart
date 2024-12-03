// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';

import '../models/books.dart';
import '../providers/book.dart';
import '../providers/category.dart';

class AddNewBookScreen extends StatefulWidget {
  const AddNewBookScreen({super.key});

  static const routeName = '/add-book-screen';

  @override
  State<AddNewBookScreen> createState() => _AddNewBookScreenState();
}

class _AddNewBookScreenState extends State<AddNewBookScreen> {
  final _globalKey = GlobalKey<FormState>();
  final _imageGlobalKey = GlobalKey<FormState>();
  DateTime? _dateTime;
  bool isLoading = false;
  Color bgColor = Colors.black;

  bool init = true;

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (_globalKey.currentState!.validate()) {
      _globalKey.currentState!.save();
      setState(() {
        isLoading = true;
      });
      if (_bookState.id.isEmpty) {
        try {
          await Provider.of<Book>(context, listen: false)
              .addNewBook(_bookState);
        } catch (error) {
          await showDialog<Null>(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                content: const Text('Xatolik!'),
                title: const Text('Mahsulot qo\'shishda xatolik!'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        try {
          await Provider.of<Book>(context, listen: false)
              .upDataBook(_bookState);
        } catch (error) {
          await showDialog<Null>(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                content: const Text('Xatolik!'),
                title: const Text('Mahsulot o\'zgartirishda xatolik!'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      }

      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
    }
  }

  @override
  void didChangeDependencies() {
    if (init) {
      final productId = ModalRoute.of(context)!.settings.arguments;
      if (productId != null) {
        final editingProduct =
            Provider.of<Book>(context).findById(productId as String);
        _bookState = editingProduct;
      }
    }
    super.didChangeDependencies();
  }

  void showCalendar(BuildContext context) {
    showDatePicker(
      context: context,
      firstDate: DateTime(1800),
      lastDate: DateTime.now(),
      currentDate: DateTime.now(),
    ).then((value) {
      if (value != null) {
        setState(() {
          _dateTime = value;
          _bookState.date = _dateTime!;
        });
      }
    });
  }

  var _bookState = Books(
    id: '',
    title: '',
    author: '',
    ganre: '',
    date: DateTime.utc(0),
    language: [''],
    pageLength: 0,
    popularity: 0,
    price: 0.0,
    imgUrl: '',
    discout: 0,
    description: '',
    bgColor: Colors.black,
    categoryId: 'c1',
    publishPlace: '',
  );

  void colorForBg() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Pick a color!'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: bgColor,
              onColorChanged: (value) {
                bgColor = value;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'BEKOR QILISH',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _bookState.bgColor = bgColor;
                });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'TANLASH',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = Provider.of<Categories>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kitob qo\'shish'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _save,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(10),
                child: Form(
                  key: _globalKey,
                  child: Column(
                    children: [
                      DropdownButton(
                        value: _bookState.categoryId,
                        isExpanded: true,
                        onChanged: (id) {
                          setState(
                            () {
                              _bookState.categoryId = id as String;
                              _bookState = Books(
                                id: _bookState.id,
                                title: _bookState.title,
                                author: _bookState.author,
                                ganre: _bookState.ganre,
                                date: _bookState.date,
                                language: _bookState.language,
                                pageLength: _bookState.pageLength,
                                popularity: _bookState.popularity,
                                price: _bookState.price,
                                imgUrl: _bookState.imgUrl,
                                discout: _bookState.discout,
                                description: _bookState.description,
                                bgColor: _bookState.bgColor,
                                categoryId: _bookState.categoryId,
                                publishPlace: _bookState.publishPlace,
                              );
                            },
                          );
                        },
                        items: categories.list.map((category) {
                          return DropdownMenuItem(
                            value: category.id,
                            child: Text(category.title),
                          );
                        }).toList(),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: _bookState.title,
                              decoration: const InputDecoration(
                                label: Text('Nomi'),
                              ),
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Iltimos, kitob nomini kiriting!';
                                } else if (value.length < 4) {
                                  return 'Kitob nomini to\'liq kiriting';
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                _bookState = Books(
                                  id: _bookState.id,
                                  title: newValue!,
                                  author: _bookState.author,
                                  ganre: _bookState.ganre,
                                  date: _bookState.date,
                                  language: _bookState.language,
                                  pageLength: _bookState.pageLength,
                                  popularity: _bookState.popularity,
                                  price: _bookState.price,
                                  imgUrl: _bookState.imgUrl,
                                  discout: _bookState.discout,
                                  description: _bookState.description,
                                  bgColor: _bookState.bgColor,
                                  categoryId: _bookState.categoryId,
                                  publishPlace: _bookState.publishPlace,
                                );
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: TextFormField(
                              initialValue: _bookState.price == 0.0
                                  ? ''
                                  : _bookState.price.toStringAsFixed(2),
                              decoration: const InputDecoration(
                                label: Text('Narxi'),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Iltimos, kitob narxini kiriting!';
                                } else if (double.tryParse(value) == null) {
                                  return 'Faqat raqam kiriting!';
                                } else if (double.parse(value) <= 1) {
                                  return 'Kitob narxini aniq kiriting!';
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                _bookState = Books(
                                  id: _bookState.id,
                                  title: _bookState.title,
                                  author: _bookState.author,
                                  ganre: _bookState.ganre,
                                  date: _bookState.date,
                                  language: _bookState.language,
                                  pageLength: _bookState.pageLength,
                                  popularity: _bookState.popularity,
                                  price: double.parse(newValue!),
                                  imgUrl: _bookState.imgUrl,
                                  discout: _bookState.discout,
                                  description: _bookState.description,
                                  bgColor: _bookState.bgColor,
                                  categoryId: _bookState.categoryId,
                                  publishPlace: _bookState.publishPlace,
                                );
                              },
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: _bookState.author,
                              decoration: const InputDecoration(
                                label: Text('Mualiffi'),
                              ),
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Iltimos, kitob mualiffi ismini kiriting!';
                                } else if (value.length < 5) {
                                  return 'Kitob mualiffi ismini to\'liq kiriting';
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                _bookState = Books(
                                  id: _bookState.id,
                                  title: _bookState.title,
                                  author: newValue!,
                                  ganre: _bookState.ganre,
                                  date: _bookState.date,
                                  language: _bookState.language,
                                  pageLength: _bookState.pageLength,
                                  popularity: _bookState.popularity,
                                  price: _bookState.price,
                                  imgUrl: _bookState.imgUrl,
                                  discout: _bookState.discout,
                                  description: _bookState.description,
                                  bgColor: _bookState.bgColor,
                                  categoryId: _bookState.categoryId,
                                  publishPlace: _bookState.publishPlace,
                                );
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: TextFormField(
                              initialValue: _bookState.ganre,
                              decoration: const InputDecoration(
                                label: Text('Janri'),
                              ),
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Iltimos, kitob janrini kiriting!';
                                } else if (value.length < 5) {
                                  return 'Kitob janrini to\'liq kiriting';
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                _bookState = Books(
                                  id: _bookState.id,
                                  title: _bookState.title,
                                  author: _bookState.author,
                                  ganre: newValue!,
                                  date: _bookState.date,
                                  language: _bookState.language,
                                  pageLength: _bookState.pageLength,
                                  popularity: _bookState.popularity,
                                  price: _bookState.price,
                                  imgUrl: _bookState.imgUrl,
                                  discout: _bookState.discout,
                                  description: _bookState.description,
                                  bgColor: _bookState.bgColor,
                                  categoryId: _bookState.categoryId,
                                  publishPlace: _bookState.publishPlace,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: _bookState.pageLength == 0
                                  ? ''
                                  : _bookState.pageLength.toString(),
                              decoration: const InputDecoration(
                                label: Text('Varoqlar soni'),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Iltimos, kitob varoqlar sonini kiriting!';
                                } else if (int.tryParse(value) == null) {
                                  return 'Kitob varaqlari sonini raqamda kiriting';
                                } else if (int.parse(value) <= 10) {
                                  return 'Aniqroq kiriting';
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                _bookState = Books(
                                  id: _bookState.id,
                                  title: _bookState.title,
                                  author: _bookState.author,
                                  ganre: _bookState.ganre,
                                  date: _bookState.date,
                                  language: _bookState.language,
                                  pageLength: int.parse(newValue!),
                                  popularity: _bookState.popularity,
                                  price: _bookState.price,
                                  imgUrl: _bookState.imgUrl,
                                  discout: _bookState.discout,
                                  description: _bookState.description,
                                  bgColor: _bookState.bgColor,
                                  categoryId: _bookState.categoryId,
                                  publishPlace: _bookState.publishPlace,
                                );
                              },
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: TextFormField(
                              initialValue: _bookState.popularity == 0.0
                                  ? ''
                                  : _bookState.popularity.toStringAsFixed(1),
                              decoration: const InputDecoration(
                                label: Text('Mashxurligi'),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(5)
                              ],
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Iltimos, kitobga baho bering!';
                                } else if (double.tryParse(value) == null) {
                                  return 'Kitob bahosini raqamda kiriting';
                                } else if (double.parse(value) < 0) {
                                  return 'Kitob bahosi 0 dan kichik bo\'lmasligi lozim';
                                } else if (double.parse(value) > 5) {
                                  return 'Kitob bahosi 5 dan katta bo\'lmasligi lozim';
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                _bookState = Books(
                                  id: _bookState.id,
                                  title: _bookState.title,
                                  author: _bookState.author,
                                  ganre: _bookState.ganre,
                                  date: _bookState.date,
                                  language: _bookState.language,
                                  pageLength: _bookState.pageLength,
                                  popularity: double.parse(newValue!),
                                  price: _bookState.price,
                                  imgUrl: _bookState.imgUrl,
                                  discout: _bookState.discout,
                                  description: _bookState.description,
                                  bgColor: _bookState.bgColor,
                                  categoryId: _bookState.categoryId,
                                  publishPlace: _bookState.publishPlace,
                                );
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: TextFormField(
                              initialValue: '${_bookState.discout}',
                              decoration: const InputDecoration(
                                label: Text('Chegirma %'),
                              ),
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Iltimos, kitobga chegirmasini kiriting!';
                                } else if (int.tryParse(value) == null) {
                                  return 'Kitob chegirmasini raqamda kiriting';
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                _bookState = Books(
                                  id: _bookState.id,
                                  title: _bookState.title,
                                  author: _bookState.author,
                                  ganre: _bookState.ganre,
                                  date: _bookState.date,
                                  language: _bookState.language,
                                  pageLength: _bookState.pageLength,
                                  popularity: _bookState.popularity,
                                  price: _bookState.price,
                                  imgUrl: _bookState.imgUrl,
                                  discout: int.parse(newValue!),
                                  description: _bookState.description,
                                  bgColor: _bookState.bgColor,
                                  categoryId: _bookState.categoryId,
                                  publishPlace: _bookState.publishPlace,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      TextFormField(
                        initialValue: _bookState.language[0],
                        decoration: const InputDecoration(
                          label: Text('Tili'),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Iltimos, kitob tilini kiriting!';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _bookState = Books(
                            id: _bookState.id,
                            title: _bookState.title,
                            author: _bookState.author,
                            ganre: _bookState.ganre,
                            date: _bookState.date,
                            language: [newValue!],
                            pageLength: _bookState.pageLength,
                            popularity: _bookState.popularity,
                            price: _bookState.price,
                            imgUrl: _bookState.imgUrl,
                            discout: _bookState.discout,
                            description: _bookState.description,
                            bgColor: _bookState.bgColor,
                            categoryId: _bookState.categoryId,
                            publishPlace: _bookState.publishPlace,
                          );
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      TextFormField(
                        initialValue: _bookState.publishPlace,
                        decoration: const InputDecoration(
                          label: Text('Ishlab chiqarilgan tashkilot'),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Iltimos, kitobni ishlab chiqargan tashkilot nomini kiriting!';
                          } else if (value.length < 5) {
                            return 'kitobni ishlab chiqargan tashkilot nomini to\'liq kiriting';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _bookState = Books(
                            id: _bookState.id,
                            title: _bookState.title,
                            author: _bookState.author,
                            ganre: _bookState.ganre,
                            date: _bookState.date,
                            language: _bookState.language,
                            pageLength: _bookState.pageLength,
                            popularity: _bookState.popularity,
                            price: _bookState.price,
                            imgUrl: _bookState.imgUrl,
                            discout: _bookState.discout,
                            description: _bookState.description,
                            bgColor: _bookState.bgColor,
                            categoryId: _bookState.categoryId,
                            publishPlace: newValue!,
                          );
                        },
                      ),
                      TextFormField(
                        initialValue: _bookState.description,
                        decoration: const InputDecoration(
                          alignLabelWithHint: true,
                          label: Text('Vikipediya'),
                        ),
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Iltimos, kitobning mazmunini kiriting!';
                          } else if (value.length < 10) {
                            return 'kitobni mazmunini to\'liq kiriting';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _bookState = Books(
                            id: _bookState.id,
                            title: _bookState.title,
                            author: _bookState.author,
                            ganre: _bookState.ganre,
                            date: _bookState.date,
                            language: _bookState.language,
                            pageLength: _bookState.pageLength,
                            popularity: _bookState.popularity,
                            price: _bookState.price,
                            imgUrl: _bookState.imgUrl,
                            discout: _bookState.discout,
                            description: newValue!,
                            bgColor: _bookState.bgColor,
                            categoryId: _bookState.categoryId,
                            publishPlace: _bookState.publishPlace,
                          );
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_bookState.date == DateTime.utc(0)
                              ? 'Chiqarilgan sanasi:'
                              : 'Chiqarilgan sanasi: ${DateFormat('d/MMM/yyyy').format(_bookState.date)}'),
                          TextButton(
                            onPressed: () {
                              showCalendar(context);
                            },
                            child: const Text('Sanani tanlash'),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Orqa foniga rang tanlang!'),
                          const SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                            onTap: colorForBg,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.grey.shade300, width: 2),
                                color: _bookState.bgColor == Colors.transparent
                                    ? Colors.black
                                    : _bookState.bgColor,
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            width: 100,
                            height: 140,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                              ),
                            ),
                            child: _bookState.imgUrl.isEmpty
                                ? const Text('Rasm yuklang')
                                : Image.network(_bookState.imgUrl),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: TextFormField(
                              key: _imageGlobalKey,
                              initialValue: _bookState.imgUrl,
                              decoration: const InputDecoration(
                                label: Text('Rasm URLni kiriting!'),
                              ),
                              keyboardType: TextInputType.url,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Iltimos, rasm kiritin!';
                                } else if (!value.startsWith('http')) {
                                  return 'To\'g\'ri URl kiriting!';
                                }
                                return null;
                              },
                              onFieldSubmitted: (value) {
                                setState(() {
                                  _bookState = Books(
                                    id: _bookState.id,
                                    title: _bookState.title,
                                    author: _bookState.author,
                                    ganre: _bookState.ganre,
                                    date: _bookState.date,
                                    language: _bookState.language,
                                    pageLength: _bookState.pageLength,
                                    popularity: _bookState.popularity,
                                    price: _bookState.price,
                                    imgUrl: value,
                                    discout: _bookState.discout,
                                    description: _bookState.description,
                                    bgColor: _bookState.bgColor,
                                    categoryId: _bookState.categoryId,
                                    publishPlace: _bookState.publishPlace,
                                  );
                                });
                              },
                              onSaved: (newValue) {
                                _bookState = Books(
                                  id: _bookState.id,
                                  title: _bookState.title,
                                  author: _bookState.author,
                                  ganre: _bookState.ganre,
                                  date: _bookState.date,
                                  language: _bookState.language,
                                  pageLength: _bookState.pageLength,
                                  popularity: _bookState.popularity,
                                  price: _bookState.price,
                                  imgUrl: newValue!,
                                  discout: _bookState.discout,
                                  description: _bookState.description,
                                  bgColor: _bookState.bgColor,
                                  categoryId: _bookState.categoryId,
                                  publishPlace: _bookState.publishPlace,
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
