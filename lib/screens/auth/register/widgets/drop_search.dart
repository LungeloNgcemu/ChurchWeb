
// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:flutter/material.dart';
//
// Widget dropSearch(BuildContext context, List<String> churches,
//     Function(void Function()) setState, TextEditingController controller) {
//   return Center(
//     child: DropdownButtonHideUnderline(
//       child: DropdownButton2<String>(
//         isExpanded: true,
//         hint: Text(
//           'Select Church',
//           style: TextStyle(
//             fontSize: 14,
//             color: Theme.of(context).hintColor,
//           ),
//         ),
//         items: churches
//             .map((item) => DropdownMenuItem(
//           value: item,
//           child: Text(
//             item,
//             style: const TextStyle(
//               fontSize: 14,
//             ),
//           ),
//         ))
//             .toList(),
//         value: selectedChurch,
//         onChanged: (value) {
//           setState(() {
//             selectedChurch = value;
//
//             context
//                 .read<SelectedChurchProvider>()
//                 .updateSelectedChurch(newValue: selectedChurch!);
//             getChurchCode(context, selectedChurch!);
//           });
//         },
//         buttonStyleData: const ButtonStyleData(
//           padding: EdgeInsets.symmetric(horizontal: 16),
//           height: 40,
//           width: 200,
//         ),
//         dropdownStyleData: const DropdownStyleData(
//           maxHeight: 200,
//         ),
//         menuItemStyleData: const MenuItemStyleData(
//           height: 40,
//         ),
//         dropdownSearchData: DropdownSearchData(
//           searchController: controller,
//           searchInnerWidgetHeight: 50,
//           searchInnerWidget: Container(
//             height: 50,
//             padding: const EdgeInsets.only(
//               top: 8,
//               bottom: 4,
//               right: 8,
//               left: 8,
//             ),
//             child: TextFormField(
//               expands: true,
//               maxLines: null,
//               controller: controller,
//               decoration: InputDecoration(
//                 isDense: true,
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 10,
//                   vertical: 8,
//                 ),
//                 hintText: 'Search for a Church...',
//                 hintStyle: const TextStyle(fontSize: 12),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//             ),
//           ),
//           searchMatchFn: (item, searchValue) {
//             return item.value.toString().contains(searchValue);
//           },
//         ),
//         //This to clear the search value when you close the menu
//         onMenuStateChange: (isOpen) {
//           if (!isOpen) {
//             controller.clear();
//           }
//         },
//       ),
//     ),
//   );
// }