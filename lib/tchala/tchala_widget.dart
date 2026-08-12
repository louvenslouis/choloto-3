import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sticky_headers/sticky_headers.dart';

import 'tchala_data_repository.dart';
export 'tchala_model.dart';

class TchalaWidget extends StatefulWidget {
  const TchalaWidget({super.key});

  static String routeName = 'Tchala';
  static String routePath = '/tchala';

  @override
  State<TchalaWidget> createState() => _TchalaWidgetState();
}

class _TchalaWidgetState extends State<TchalaWidget>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  late final TabController _tabController;
  late Future<TchalaData> _data;

  @override
  void initState() {
    super.initState();
    logFirebaseEvent('screen_view', parameters: {'screen_name': 'Tchala'});
    _tabController = TabController(length: 2, vsync: this);
    _data = tchalaDataRepository.load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _retryLoading() {
    setState(() {
      _data = tchalaDataRepository.reload();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        automaticallyImplyLeading: false,
        title: Text(
          FFLocalizations.of(context).getText('z0x7hmij' /* tchala */),
          style: theme.headlineMedium.override(
            fontFamily: 'Google sans flex',
            color: Colors.white,
            fontSize: 22.0,
            letterSpacing: 0.0,
          ),
        ),
        centerTitle: false,
        elevation: 2.0,
      ),
      body: SafeArea(
        top: true,
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              labelColor: theme.primaryText,
              unselectedLabelColor: theme.secondaryText,
              labelStyle: theme.titleMedium.override(
                fontFamily: 'Google sans flex',
                letterSpacing: 0.0,
              ),
              unselectedLabelStyle: theme.titleMedium.override(
                fontFamily: 'Google sans flex',
                letterSpacing: 0.0,
              ),
              indicatorColor: theme.primary,
              tabs: [
                Tab(
                  text: FFLocalizations.of(context)
                      .getText('40q38tw9' /* Tchala */),
                ),
                Tab(
                  text: FFLocalizations.of(context)
                      .getText('d4x9buzb' /* Saints */),
                ),
              ],
            ),
            Expanded(
              child: FutureBuilder<TchalaData>(
                future: _data,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return Center(
                      child: CircularProgressIndicator(color: theme.primary),
                    );
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return _LoadError(onRetry: _retryLoading);
                  }

                  final data = snapshot.requireData;
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _TchalaList(entries: data.symbols),
                      _SaintsList(months: data.saintMonths),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TchalaList extends StatelessWidget {
  const _TchalaList({required this.entries});

  final List<TchalaEntry> entries;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: const PageStorageKey('tchala-list'),
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 2.0),
      itemBuilder: (context, index) => _TchalaCard(entry: entries[index]),
    );
  }
}

class _TchalaCard extends StatelessWidget {
  const _TchalaCard({required this.entry});

  final TchalaEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final label = FFLocalizations.of(context).getVariableText(
      frText: entry.frenchTranslation,
      enText: entry.frenchTranslation,
      crText: entry.creoleSymbol,
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      color: theme.secondaryBackground,
      elevation: 0.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                label,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.bodyMedium.override(
                  font: GoogleFonts.inter(
                    fontWeight: theme.bodyMedium.fontWeight,
                    fontStyle: theme.bodyMedium.fontStyle,
                  ),
                  letterSpacing: 0.0,
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final number in entry.associatedNumbers) ...[
                      _NumberBadge(number: number),
                      const SizedBox(width: 3.0),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberBadge extends StatelessWidget {
  const _NumberBadge({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Semantics(
      label: number.toString(),
      child: Container(
        width: 50.0,
        height: 50.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: theme.primary, shape: BoxShape.circle),
        child: Text(
          number.toString(),
          style: theme.bodyMedium.override(
            font: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontStyle: theme.bodyMedium.fontStyle,
            ),
            letterSpacing: 0.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _SaintsList extends StatelessWidget {
  const _SaintsList({required this.months});

  final List<SaintMonth> months;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: const PageStorageKey('saints-list'),
      itemCount: months.length,
      itemBuilder: (context, index) => _SaintMonthSection(month: months[index]),
    );
  }
}

class _SaintMonthSection extends StatelessWidget {
  const _SaintMonthSection({required this.month});

  final SaintMonth month;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return StickyHeader(
      overlapHeaders: false,
      header: Container(
        width: double.infinity,
        height: 50.0,
        padding: const EdgeInsetsDirectional.only(start: 16.0),
        alignment: AlignmentDirectional.centerStart,
        color: theme.primaryBackground,
        child: Text(
          month.name,
          style: theme.titleLarge.override(
            fontFamily: 'Google sans flex',
            letterSpacing: 0.0,
          ),
        ),
      ),
      content: Column(
        children: [for (final saint in month.saints) _SaintRow(saint: saint)],
      ),
    );
  }
}

class _SaintRow extends StatelessWidget {
  const _SaintRow({required this.saint});

  final SaintEntry saint;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      height: 70.0,
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 10.0, 16.0, 10.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        border: Border(bottom: BorderSide(color: theme.primaryBackground)),
      ),
      child: Row(
        children: [
          Container(
            width: 50.0,
            height: 50.0,
            alignment: Alignment.center,
            decoration:
                BoxDecoration(color: theme.primary, shape: BoxShape.circle),
            child: Text(
              saint.date,
              textAlign: TextAlign.center,
              style: theme.bodyMedium.override(
                font: GoogleFonts.plusJakartaSans(
                  fontWeight: theme.bodyMedium.fontWeight,
                  fontStyle: theme.bodyMedium.fontStyle,
                ),
                color: Colors.white,
                fontSize: 12.0,
                letterSpacing: 0.0,
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              saint.name,
              style: theme.bodyLarge.override(
                font: GoogleFonts.inter(
                  fontWeight: theme.bodyLarge.fontWeight,
                  fontStyle: theme.bodyLarge.fontStyle,
                ),
                letterSpacing: 0.0,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: theme.secondaryText,
            size: 24.0,
          ),
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final localizations = FFLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              localizations.getVariableText(
                frText: 'Impossible de charger les données Tchala.',
                enText: 'Unable to load the Tchala data.',
                crText: 'Nou pa ka chaje done Tchala yo.',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12.0),
            OutlinedButton(
              onPressed: onRetry,
              child: Text(
                localizations.getVariableText(
                  frText: 'Réessayer',
                  enText: 'Try again',
                  crText: 'Eseye ankò',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
