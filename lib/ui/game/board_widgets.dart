/// Kasaba istek panosu, haftalık sefer kartı ve mektup kutusu.
library;

import 'package:flutter/material.dart';

import '../../game/quests.dart';
import '../theme.dart';
import '../widgets/dk_icon.dart';
import '../widgets/emoji_text.dart';
import '../widgets/hand.dart';
import '../widgets/ikon.dart';
import '../widgets/kit.dart';
import 'game_theme.dart';

/// Günün üç isteği. Tamamlanan isteğin ödülü elle alınır (çocuk ödülü
/// kendisi toplar; kaçırılan istek hiçbir şey eksiltmez).
class QuestBoard extends StatefulWidget {
  const QuestBoard({super.key});

  @override
  State<QuestBoard> createState() => _QuestBoardState();
}

class _QuestBoardState extends State<QuestBoard> {
  Future<DailyBoard>? _f;
  String _key = '';

  Future<void> _claim(int i, Quest q) async {
    final app = AppScope.read(context);
    if (!await app.claimQuest(i)) return;
    if (!mounted) return;
    final text =
        '${q.who.name} teşekkür etti: ${q.light} ışık ve ${q.qty} ${q.supply.label.toLowerCase()}!';
    app.say(text);
    showDkToast(context, DkIcons.star, text);
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final b = app.game.board;
    final key = '${app.active?.id}|${app.clock().day}|'
        '${b?.counts}|${b?.claimed.length}';
    if (_f == null || key != _key) {
      _key = key;
      _f = app.todayBoard();
    }
    return FutureBuilder<DailyBoard>(
      future: _f,
      builder: (context, snap) {
        final board = snap.data;
        if (board == null) return const SizedBox.shrink();
        // Claude Design 26: tahta pano, raptiyeli kâğıt notlar
        return Column(
          key: const Key('quest-board'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('İSTEK PANOSU', style: G.kicker),
            const SizedBox(height: 2),
            const Text('Komşuların bugün senden yardım istiyor.',
                style: G.soft),
            const SizedBox(height: 8),
            HandBox(
              style: HandStyle.pano,
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < board.quests.length; i++) ...[
                    if (i > 0) const SizedBox(height: 14),
                    Transform.rotate(
                      angle: const [-.026, .021, -.014][i % 3],
                      child: _QuestRow(
                        key: Key('quest-$i'),
                        quest: board.quests[i],
                        progress: board.progressOf(board.quests[i]),
                        claimed: board.claimed.contains(i),
                        onClaim: board.canClaim(i)
                            ? () => _claim(i, board.quests[i])
                            : null,
                        index: i,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _QuestRow extends StatelessWidget {
  const _QuestRow({
    super.key,
    required this.quest,
    required this.progress,
    required this.claimed,
    required this.onClaim,
    required this.index,
  });
  final Quest quest;
  final int progress;
  final bool claimed;
  final VoidCallback? onClaim;
  final int index;

  @override
  Widget build(BuildContext context) {
    final q = quest;
    final done = progress >= q.target;
    Widget chip(Widget icon, String n) => Container(
          padding: const EdgeInsets.fromLTRB(6, 2, 8, 3),
          decoration: BoxDecoration(
            color: const Color(0xFFF2D492),
            border: Border.all(color: K.murekkep, width: 1.5),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            icon,
            const SizedBox(width: 3),
            Text(n,
                style: const TextStyle(
                    fontFamily: K.display,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: K.murekkep)),
          ]),
        );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(12, 18, 12, 10),
          decoration: BoxDecoration(
            color: claimed ? K.kagit2 : K.kagit3,
            border: Border.all(color: K.murekkep, width: 2),
            boxShadow: const [
              BoxShadow(color: Color(0x592B2320), offset: Offset(3, 4))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: K.kagit2,
                    shape: BoxShape.circle,
                    border: Border.all(color: K.murekkep, width: 2),
                  ),
                  child: EmojiImage(q.who.emoji, size: 30),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${q.who.name}: “${q.plea}”',
                          style: G.hand.copyWith(
                              fontSize: 17, color: K.murekkep)),
                      const SizedBox(height: 4),
                      Text(q.task,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: K.murekkep2)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text('Ödül:',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700)),
                          chip(const IkonView(Ikon.isik, size: 18), '${q.light}'),
                          chip(IkonView(ikonOf(q.supply), size: 18), '${q.qty}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: Semantics(
                    label: '${q.task} $progress / ${q.target}',
                    child: ExcludeSemantics(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: q.target == 0 ? 1 : progress / q.target,
                          minHeight: 8,
                          backgroundColor: K.kagit2,
                          color: done ? K.zumrut : K.safran,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('$progress / ${q.target}',
                    style: const TextStyle(
                        fontFamily: K.display,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                if (claimed)
                  const IkonView(Ikon.tik, size: 28)
                else if (done)
                  SizedBox(
                    width: 96,
                    child: ChunkyButton(
                      key: Key('quest-claim-$index'),
                      label: 'Al',
                      height: 48,
                      kind: BtnKind.good,
                      semanticsLabel: '${q.who.name}: ödülü al',
                      onPressed: onClaim,
                    ),
                  ),
              ]),
            ],
          ),
        ),
        // raptiye
        Positioned(
          top: 4,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: K.kok,
                shape: BoxShape.circle,
                border: Border.all(color: K.murekkep, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Haftalık sefer: haftada [weeklyGoalDays] farklı gün yola çıkmak.
class WeeklyTripCard extends StatelessWidget {
  const WeeklyTripCard({super.key});

  Future<void> _claim(BuildContext context) async {
    final app = AppScope.read(context);
    final k = app.thisTrip().leaderKingdom;
    if (!await app.claimTrip()) return;
    if (!context.mounted) return;
    final text = 'Sefer tamam! ${k.leader} sana bir mektup yazdı.';
    app.say(text);
    showDkToast(context, DkIcons.star, text);
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = app.thisTrip();
    final k = t.leaderKingdom;
    final monday = DateTime.parse(t.week);
    const names = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    String key(int i) {
      final d = DateTime(monday.year, monday.month, monday.day + i);
      String two(int n) => n.toString().padLeft(2, '0');
      return '${d.year}-${two(d.month)}-${two(d.day)}';
    }

    return Parchment(
      key: const Key('weekly-trip'),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            EmojiImage(k.emoji, size: 36),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('HAFTALIK SEFER', style: G.kicker),
                  Text(
                      t.claimed
                          ? 'Bu haftanın seferi tamam!'
                          : 'Bu hafta $weeklyGoalDays gün yola çık.',
                      style: G.sub),
                  Text(
                      t.claimed
                          ? 'Pazartesi yeni sefer başlıyor.'
                          : '${k.leader} seni bekliyor; seferin sonunda sana mektup yazacak.',
                      style: G.soft),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < 7; i++)
                Column(children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: t.days.contains(key(i)) ? k.color : G.paper,
                      border: Border.all(color: G.ink, width: 2),
                    ),
                    child: t.days.contains(key(i))
                        ? const DkIcon(DkIcons.check,
                            size: 18, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 2),
                  Text(names[i], style: G.soft.copyWith(fontSize: 12)),
                ]),
            ],
          ),
          if (t.canClaim) ...[
            const SizedBox(height: 12),
            ChunkyButton(
              key: const Key('trip-claim'),
              label: 'Seferi tamamla',
              kind: BtnKind.good,
              onPressed: () => _claim(context),
            ),
          ] else if (!t.claimed) ...[
            const SizedBox(height: 6),
            Text('${t.days.length} / $weeklyGoalDays gün',
                style: G.soft, textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}

/// Mektup kutusu düğmesi (okunmamış sayısıyla).
class MailboxButton extends StatelessWidget {
  const MailboxButton({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final unread = app.game.unreadLetters;
    return Pressable(
      key: const Key('mail-open'),
      label: unread > 0 ? 'Mektuplar, $unread yeni' : 'Mektuplar',
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => const LettersScreen())),
      builder: (context, down) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: down ? G.paper2 : (unread > 0 ? G.saffron : Colors.white),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: G.ink, width: 2),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const EmojiImage('✉️', size: 22),
          if (unread > 0) ...[
            const SizedBox(width: 6),
            Text('$unread',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w900, color: G.ink)),
          ],
        ]),
      ),
    );
  }
}

/// Mektuplar: önderlerden, bekçilerden ve Anka'dan. Tahta zemin üstünde
/// mühürlü zarflar (Claude Design 30).
class LettersScreen extends StatelessWidget {
  const LettersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final letters = app.game.letters.reversed.toList();
    return Scaffold(
      backgroundColor: G.paper,
      body: SafeArea(
        child: ChildTextScale(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(children: [
                CircleBtn(
                  key: const Key('mail-back'),
                  icon: DkIcons.left,
                  label: 'Geri',
                  size: 56,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 12),
                const Expanded(child: Text('Mektuplar', style: G.title)),
              ]),
            ),
            Expanded(
              child: letters.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                          'Henüz mektup yok. Bir bekçiyi kurtarınca ya da haftalık seferi bitirince mektup gelir.',
                          style: G.body),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: letters.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, i) {
                        final l = letters[i];
                        return Pressable(
                          key: Key('letter-$i'),
                          label: '${l.from} mektubu${l.read ? '' : ', yeni'}',
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                  builder: (_) => LetterScreen(letter: l))),
                          builder: (context, down) => _Envelope(
                              letter: l, pressed: down),
                        );
                      },
                    ),
            ),
          ]),
        ),
      ),
    );
  }
}

String _initials(String name) {
  final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '';
  return parts.length == 1
      ? parts.first.characters.first
      : '${parts.first.characters.first}${parts.last.characters.first}';
}

/// Zarf: üstte kapak, ortada kök boya mühür.
class _Envelope extends StatelessWidget {
  const _Envelope({required this.letter, required this.pressed});
  final Letter letter;
  final bool pressed;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 132,
        child: CustomPaint(
          painter: _EnvelopePainter(open: letter.read, pressed: pressed),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              EmojiImage(letter.emoji, size: 34),
              const SizedBox(width: 8),
              Expanded(
                child: Text(letter.from,
                    style: G.hand.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: K.murekkep)),
              ),
              if (!letter.read)
                const Text('YENİ',
                    style: TextStyle(
                        fontFamily: K.display,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: K.kok)),
            ]),
          ),
        ),
      );
}

class _EnvelopePainter extends CustomPainter {
  _EnvelopePainter({required this.open, required this.pressed});
  final bool open;
  final bool pressed;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final body = Rect.fromLTWH(2, 2, w - 4, h - 6);
    final ink = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeJoin = StrokeJoin.round
      ..color = K.murekkep;
    canvas.drawRect(body.shift(const Offset(3, 4)),
        Paint()..color = const Color(0x592B2320));
    canvas.drawRect(body, Paint()..color = pressed ? K.kagit : K.kagit2);
    final flap = Path()
      ..moveTo(body.left, body.top)
      ..lineTo(w / 2, body.top + h * .5)
      ..lineTo(body.right, body.top)
      ..close();
    canvas.drawPath(
        flap, Paint()..color = open ? K.kagit3 : const Color(0xFFD9C6A2));
    canvas.drawPath(flap, ink);
    canvas.drawRect(body, ink);
    if (!open) {
      final c = Offset(w / 2, body.top + h * .5);
      canvas.drawCircle(c, 18, Paint()..color = K.kokKoyu);
      canvas.drawCircle(c, 18, ink);
    }
  }

  @override
  bool shouldRepaint(_EnvelopePainter old) =>
      old.open != open || old.pressed != pressed;
}

/// Tek mektup: tahta zemin, mühürlü zarf, çizgili kâğıtta el yazısı.
class LetterScreen extends StatefulWidget {
  const LetterScreen({super.key, required this.letter});
  final Letter letter;

  @override
  State<LetterScreen> createState() => _LetterScreenState();
}

class _LetterScreenState extends State<LetterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _read());
  }

  void _read() {
    final app = AppScope.read(context);
    app.readLetter(widget.letter);
    app.say(widget.letter.text);
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.letter;
    final lines = l.text.split('\n').where((t) => t.trim().isNotEmpty).toList();
    const lh = 32.0;
    return Scaffold(
      backgroundColor: const Color(0xFF9A6838),
      body: CustomPaint(
        painter: _PlanksPainter(),
        child: SafeArea(
          child: ChildTextScale(
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Row(children: [
                  CircleBtn(
                    key: const Key('letter-back'),
                    icon: DkIcons.left,
                    label: 'Geri',
                    size: 56,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  const Text('Sesli oku',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: K.kagit3)),
                  const SizedBox(width: 10),
                  CircleBtn(
                    key: const Key('letter-listen'),
                    icon: DkIcons.volume,
                    label: 'Mektubu dinle',
                    size: 64,
                    bg: K.safran,
                    onPressed: () => AppScope.read(context).say(l.text),
                  ),
                ]),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 16, 18, 24),
                  child: Transform.rotate(
                    angle: -.026,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
                      decoration: BoxDecoration(
                        color: K.kagit3,
                        border: Border.all(color: K.murekkep, width: 2),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x592B2320), offset: Offset(4, 6))
                        ],
                      ),
                      child: CustomPaint(
                        painter: _LinedPainter(lh),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (var i = 0; i < lines.length; i++)
                              Text(lines[i],
                                  textAlign: i >= lines.length - 2 &&
                                          lines.length > 2
                                      ? TextAlign.right
                                      : TextAlign.left,
                                  style: G.hand.copyWith(
                                      fontSize: i == lines.length - 1 ? 24 : 19,
                                      height: lh /
                                          (i == lines.length - 1 ? 24 : 19),
                                      fontWeight: i == lines.length - 1
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: K.murekkep)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _PlanksPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const planks = [
      (3.0, Color(0xFF9A6838)),
      (2.0, Color(0xFF8E5E31)),
      (6.0, Color(0xFFA0703F)),
      (1.0, Color(0xFF87582E)),
    ];
    var x = 0.0;
    var i = 0;
    while (x < size.width) {
      final (bw, c) = planks[i % planks.length];
      canvas.drawRect(Rect.fromLTWH(x, 0, bw, size.height), Paint()..color = c);
      x += bw;
      i++;
    }
  }

  @override
  bool shouldRepaint(_PlanksPainter old) => false;
}

/// Çizgili mektup kâğıdı.
class _LinedPainter extends CustomPainter {
  _LinedPainter(this.lh);
  final double lh;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0x241F4E79)
      ..strokeWidth = 1;
    for (var y = lh - 1; y < size.height; y += lh) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(_LinedPainter old) => old.lh != lh;
}
