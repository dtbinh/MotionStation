% EIG �́A�ŗL�l�ƌŗL�x�N�g�����v�Z���܂��B
% 
% E = EIG(X) �́A�����s�� X �̌ŗL�l���܂ރx�N�g���ł��B
%
% [V,D] = EIG(X) �́A�ŗL�l��Ίp�v�f�Ƃ���s�� D �Ɗe�񂪁A�Ή�����ŗL
% �x�N�g������Ȃ�t���s�� V ���o�͂��܂��B�����̊Ԃɂ́AX*V = V*D ��
% ���藧���܂��B
% 
% [V,D] = EIG(X,'nobalance') �́A���t�����s��Ȃ��Ōv�Z���܂��B���̕��@
% �́A�ʏ�̃X�P�[�����O���g��Ȃ��ŁA������ɑ΂��Ă�萸�x�̍�����
% �ʂ��o�͂���ꍇ������܂��BX ���Ώ̂̏ꍇ�́AEIG(X,'nobalance') �́AX 
% �����ɕ��t������Ă���̂Ŗ�������܂��B
% 
% E = EIG(A,B) �́A�����s�� A �� B �̈�ʉ��ŗL�l����Ȃ�x�N�g�� E ���o
% �͂��܂��B
%
% [V,D] = EIG(A,B) �́A��ʉ��ŗL�l��Ίp�v�f�Ƃ���s�� D �Ɗe�񂪁A�Ή�
% ����ŗL�x�N�g������Ȃ�t���s�� V ���o�͂��܂��B�����̊Ԃɂ́AA*V = 
% B*V*D �����藧���܂��B
%
% EIG(A,B,'chol') �́A�Ώ̍s�� A �� �Ώ̐���s�� B �ɑ΂��āAEIG(A,B) ��
% �����ł��BB ��Cholesky �������g���āAA �� B �̈�ʉ��ŗL�l���v�Z���܂��B
%  
% EIG(A,B,'qz') �́AA �� B �̑Ώ̐��𖳎����AQZ �A���S���Y�����g���܂��B
% 
% ��ʂɁA��̃A���S���Y���͓������ʂ��o�͂��܂����AQZ �A���S���Y��
% ���g�p����ق���������ł���\��������܂��B
% �t���O�́AA �� B ���Ώ̂łȂ��ꍇ�ɂ͖�������܂��B
%
% �Q�l�FCONDEIG, EIGS.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 01:59:46 $
%   Built-in function.