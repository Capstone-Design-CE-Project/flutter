import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../navigation/prototype_routes.dart';
import '../widgets/device_clock.dart';

class SplashtitleWidget extends StatefulWidget {
  const SplashtitleWidget({super.key});

  @override
  State<SplashtitleWidget> createState() => _SplashtitleWidgetState();
}

class _SplashtitleWidgetState extends State<SplashtitleWidget> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = math
            .min(constraints.maxWidth / 402, constraints.maxHeight / 874)
            .clamp(0.7, 1.2)
            .toDouble();

        return DefaultTextStyle.merge(
          style: const TextStyle(decoration: TextDecoration.none),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(26, 43, 73, 1),
              image: DecorationImage(
                image: AssetImage('asset/images/Bgcontainer.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Color.fromRGBO(26, 43, 73, 0.5),
                  BlendMode.darken,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20 * scale,
                    vertical: 8 * scale,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DeviceClock(color: Colors.white, fontSize: 12 * scale),
                        SizedBox(width: 8 * scale),
                        SvgPicture.asset(
                          'asset/images/vector0.svg',
                          width: 12 * scale,
                          height: 12 * scale,
                          semanticsLabel: 'signal',
                        ),
                        SizedBox(width: 4 * scale),
                        SvgPicture.asset(
                          'asset/images/vector1.svg',
                          width: 12 * scale,
                          height: 12 * scale,
                          semanticsLabel: 'wifi',
                        ),
                        SizedBox(width: 4 * scale),
                        SvgPicture.asset(
                          'asset/images/vector2.svg',
                          width: 16 * scale,
                          height: 12 * scale,
                          semanticsLabel: 'battery',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32 * scale),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '기억의 조각',
                            softWrap: false,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'GowunBatang',
                              fontSize: 40 * scale,
                              fontWeight: FontWeight.w400,
                              decoration: TextDecoration.none,
                              height: 1,
                            ),
                          ),
                        ),
                        SizedBox(height: 16 * scale),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '소중한 기억을 함께 지켜갑니다',
                            softWrap: false,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'GowunBatang',
                              fontSize: 18 * scale,
                              fontWeight: FontWeight.w400,
                              decoration: TextDecoration.none,
                              height: 1,
                            ),
                          ),
                        ),
                        SizedBox(height: 48 * scale),
                        _LoginButton(
                          label: '내담자 로그인',
                          route: PrototypeRoutes.clientLogin,
                          filled: true,
                          scale: scale,
                        ),
                        SizedBox(height: 16 * scale),
                        _LoginButton(
                          label: '상담사 로그인',
                          route: PrototypeRoutes.counselorLogin,
                          filled: false,
                          scale: scale,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 18 * scale),
                  child: Container(
                    width: 134 * scale,
                    height: 5 * scale,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({
    required this.label,
    required this.route,
    required this.filled,
    required this.scale,
  });

  final String label;
  final String route;
  final bool filled;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16 * scale),
        color: filled
            ? const Color.fromRGBO(255, 107, 83, 1)
            : Colors.transparent,
        border: filled
            ? null
            : Border.all(color: Colors.white, width: 1.5 * scale),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 18 * scale,
        vertical: 18 * scale,
      ),
      child: FlowAction(
        route: route,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'GowunBatang',
            fontSize: 16 * scale,
            fontWeight: FontWeight.w400,
            decoration: TextDecoration.none,
            height: 1,
          ),
        ),
      ),
    );
  }
}
