// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';

class TimelineTitle extends StatelessWidget {
  final String title;

  const TimelineTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textScaleFactor: 1.1,
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
