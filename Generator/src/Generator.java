import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.util.Random;

public class Generator
{
	public static Random random = new Random();
	public static int opIndex, regAIndex, regBIndex, regCIndex, shamt;
	
	public static String[] instructions = new String[]{"ADD", "ADDz", "SUB", "AND", "NOR", "SLL", "SRL", "SRA"};
	public static String[] registers = new String[]{"R1", "R2", "R3", "R4", "R5", "R6", "R7", "R8", "R9", "R10", "R11", "R12", "R13", "R14", "R15", };
	public static String COMMA = ", ";
	public static String SPACE = " ";
	
	public static void main(String[] args) throws FileNotFoundException
	{
		int NUM_INSTRUCTIONS = 65000;
		PrintWriter writer = new PrintWriter("random.asm");
		
		for(int i = 0; i < NUM_INSTRUCTIONS; i++)
		{
			writer.println(buildInstruction());
		}	
		
		writer.close();
	}
	
	public static String buildInstruction()
	{
		String instr = "";
		
		opIndex = (int)(random.nextFloat()*(instructions.length-1));
		regAIndex = (int)(random.nextFloat()*(registers.length-1));
		regBIndex = (int)(random.nextFloat()*(registers.length-1));
		regCIndex = (int)(random.nextFloat()*(registers.length-1));
		shamt = (int)(random.nextFloat()*15);
		
		instr += instructions[opIndex];
		
		if(instr.equals("SLL") || instr.equals("SRL") || instr.equals("SRA"))
		{
			instr += SPACE;
			instr += registers[regAIndex];
			instr += COMMA;
			instr += registers[regBIndex];
			instr += COMMA;
			instr += shamt;
		}
		else
		{
			instr += SPACE;
			instr += registers[regAIndex];
			instr += COMMA;
			instr += registers[regBIndex];
			instr += COMMA;
			instr += registers[regCIndex];
		}
		
		return instr;
	}
}