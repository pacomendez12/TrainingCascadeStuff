#include <iostream>
#include <ostream>
#include <fstream>
#include <sstream>

#define EXTENSION ".pgm"

#define POS_PREFIX "pos/pos-"
#define POS_NUMBER_IMAGES 550
#define POS_OUTPUT_FILE "cars.info"

#define NEG_PREFIX "neg/neg-"
#define NEG_NUMBER_IMAGES 500
#define NEG_OUTPUT_FILE "bg.txt"

using namespace std;

int main()
{
    ofstream stm(POS_OUTPUT_FILE, ios::trunc);
    if(stm.is_open())
    {
        for (int i = 0; i < POS_NUMBER_IMAGES; i++)
        {
            stringstream sstm;
            sstm << POS_PREFIX;
            sstm << i;
            sstm << EXTENSION;

            // adding data
            sstm << " 1 0 0 100 40";
            string str = sstm.str();
            cout << str.c_str() << endl;
            stm << str << endl;
        }
        stm.close();
    }

    ofstream neg_stm(NEG_OUTPUT_FILE, ios::trunc);
    if(neg_stm.is_open())
    {
        for (int i = 0; i < NEG_NUMBER_IMAGES; i++)
        {
            stringstream sstm;
            sstm << NEG_PREFIX;
            sstm << i;
            sstm << EXTENSION;
            string str = sstm.str();
            cout << str.c_str() << endl;
            neg_stm << str << endl;
        }
        neg_stm.close();
    }


    return 0;
}
