/// Kasaba istek panosu, haftalık sefer kartı ve mektup kutusu.
library;

import 'package:flutter/material.dart';

import '../../game/quests.dart';
import '../../game/world.dart';
import '../theme.dart';
import '../widgets/dk_icon.dart';
import '../widgets/emoji_text.dart';
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
        return Column(
          key: const Key('quest-board'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('İSTEK PANOSU', style: G.kicker),
            const SizedBox(height: 2),
            const Text('Komşuların bugün senden yardım istiyor.',
                style: G.soft),
            const SizedBox(height: 8),
            for (var i = 0; i < board.quests.length; i++) ...[
              _QuestRow(
                key: Key('quest-$i'),
                quest: board.quests[i],
                progress: board.progressOf(board.quests[i]),
                claimed: board.claimed.contains(i),
                onClaim: board.canClaim(i)
                    ? () => _claim(i, board.quests[i])
                    : null,
                index: i,
              ),
              const SizedBox(height: 8),
            ],
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: claimed ? G.paper : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: done ? G.emerald : G.paper2, width: 2),
      ),
      child: Row(children: [
        EmojiImage(q.who.emoji, size: 40),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(q.who.name, style: G.kicker.copyWith(color: G.inkSoft)),
              Text(q.task, style: G.sub),
              if (!done)
                Text('“${q.plea}”', style: G.soft)
              else if (!claimed)
                const Text('Tamamlandı! Ödülünü al.', style: G.soft),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: q.target == 0 ? 1 : progress / q.target,
                  minHeight: 8,
                  backgroundColor: G.paper2,
                  color: done ? G.emerald : G.saffron,
                  semanticsLabel: '${q.task} $progress / ${q.target}',
                ),
              ),
              const SizedBox(height: 4),
              EmojiText(
                  '$progress / ${q.target} · Ödül: ${q.light} $lightEmoji '
                  '${q.qty} ${q.supply.emoji}',
                  style: G.soft),
            ],
          ),
        ),
        const SizedBox(width: 8),
        if (claimed)
          const DkIcon(DkIcons.check, size: 30, color: G.emerald)
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
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const LettersScreen())),
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

/// Mektuplar: önderlerden, bekçilerden ve Anka'dan.
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
              padding: const EdgeInsets.fromLTRB(12, 8, 16, 4),
              child: Row(children: [
                CircleBtn(
                  key: const Key('mail-back'),
                  icon: DkIcons.left,
                  label: 'Geri',
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 10),
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
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final l = letters[i];
                        return Pressable(
                          key: Key('letter-$i'),
                          label: '${l.from}: ${l.text}',
                          onTap: () {
                            app.readLetter(l);
                            app.say(l.text);
                          },
                          builder: (context, down) => Parchment(
                            color: l.read ? G.paper : Colors.white,
                            border: l.read ? G.inkSoft : G.ink,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  EmojiImage(l.emoji, size: 30),
                                  const SizedBox(width: 8),
                                  Expanded(
                                      child: Text(l.from, style: G.sub)),
                                  if (!l.read)
                                    const Text('YENİ', style: G.kicker),
                                ]),
                                const SizedBox(height: 6),
                                Text(l.text, style: G.body),
                              ],
                            ),
                          ),
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
