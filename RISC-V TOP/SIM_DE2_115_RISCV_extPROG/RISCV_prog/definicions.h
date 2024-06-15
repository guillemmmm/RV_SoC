/*
 * definicions.h
 *
 *  Created on: 1 nov. 2023
 *      Author: guill
 */

#ifndef DEFINICIONS_H_
#define DEFINICIONS_H_

#define ComparatorChangeState
#define timerChangeState
//#define PotenReg
#define UARTEn

//El Bemf es pot commutar de dos maneres
//Per velocitat (no definit)
//Per deteccio consecutiva de Bemf on depen del sentit
#define OL2CL_cons //pas de OL 2 CL per deteccio de Bemfs consecutius
//#define PotenReg //regulacio velocitat amb potenciometre
//#define slowTau //ho definim si volem commutar rapid

/*
 * Si es vol enviar per UART en directe el resultats, ojo limitiem molt frequencia funcionament placa ja que falla per menys de 0.1ms de mostreig
 */



#define PWMA 0x01
#define PWMB 0x02
#define PWMC 0x03

#define PWMon 0x00
#define PWM_1 0x11
#define PWM_0  0x10

#define HIGHlvl 0x01
#define LOWlvl 0x00

#define COMPA 0x0800
#define COMPB 0x0400
#define COMPC 0x0008
#define SW1   0x1000
#define SW2   0x0100



//output to driver
#define A 0x01
#define B 0x02
#define C 0x03

//mode of driver
#define HIGH 0x01
#define FLOW 0x02
#define LOW  0x04

//State Machine
#define IDLE 0x00 //sortides a GND
#define START 0x01 //posem el motor en estat conegut per conveni S1
#define S1 0x02 // AH BL C0
#define S2 0x03 // AH B0 CL
#define S3 0x04 // AL BH C0
#define S4 0x05 // AL B0 CH
#define S5 0x06 // A0 BH CL
#define S6 0x07 // A0 BL CH
#define confSTART 0x08
#define confEND 0x09
#define ERROR 0xFF

#define SENTIT0 0x00   //S1->S6->S4->S3->S5->S2->S1
#define SENTIT1 0x01   //S1->S2->S5->S3->S4->S6->S1

#define LowADC  0x0000083E //1.7     //limit inferior ADC
#define HighADC 0x000007C2  //1.6    //limit superior ADC

#define timeout 16000000 //1 seg de timeout

//Rampa velocitats
#define VoGir 380952 //començem a uns 60rpm (lent)
#define VMaxOL 50000
#define VMaxOL2CL 60000//aixo diu el marge, essent sempre major a VMaxOL
#define DutMin 0.07
#define DutMax 0.4
#define dutyDiv 2.0

#define Vlim 100000


#define BemfMinDetections 10
#define tau 6700*10**-9*(2.2*2+10)
//#define dw0 0.00009362   //dwo=1/(2*pi*fo) on fo es freq de tall filtre) Per a frec de tall de 1700Hz, dwo=1497.93 (en unitats de clk)
                            // fo=1/(2*pi*RC) dw0=RC/16*10**6
//dw0 es la tau del circuit
#define dw0 0.00008928

//velocitat
#define StateChange 64000

//Potenciometre
#define PotPeriod 7 //cada cuantes voltes electriques (7 corresponen a 1 gir) es mesura el Potenciometre

#endif /* DEFINICIONS_H_ */
